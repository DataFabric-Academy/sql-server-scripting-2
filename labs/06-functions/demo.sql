/*
==============================================================================
 Lab 06 — Functions | Instructor Demo
 Database: AdventureWorks  (หรือ AdventureWorks2022)
 Prerequisite: setup/01-create-lab-objects.sql
==============================================================================
*/
USE AdventureWorks;
GO

PRINT N'=== Lab 06 Demo: Functions ===';
GO

/* --------------------------------------------------------------------------
   1) Scalar UDF — คืนค่าเดียว
   -------------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION Sales.ufn_MiniCustomerCity
(
    @CustID int
)
RETURNS nvarchar(15)
AS
BEGIN
    DECLARE @city nvarchar(15);

    SELECT @city = c.City
    FROM Sales.MiniCustomers AS c
    WHERE c.CustID = @CustID;

    RETURN @city;
END;
GO

SELECT
    CustID,
    CompanyName,
    Sales.ufn_MiniCustomerCity(CustID) AS CityFromUdf
FROM Sales.MiniCustomers;
GO

/* --------------------------------------------------------------------------
   2) Inline TVF — RETURN (SELECT ...) เดียว; optimizer สามารถ expand ได้
   -------------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION Sales.ufn_MiniOrdersByCustomer
(
    @CustID int
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.CustID,
        o.OrderDate,
        o.Status,
        o.Freight
    FROM Sales.MiniOrders AS o
    WHERE o.CustID = @CustID
);
GO

-- เตรียมข้อมูลตัวอย่าง (idempotent-ish)
IF NOT EXISTS (SELECT 1 FROM Sales.MiniOrders WHERE CustID = 1)
BEGIN
    INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
    VALUES (1, 'PO-DEMO-1', 12.50, 'Open'),
           (1, 'PO-DEMO-2', 8.00, 'Shipped');
END;
GO

SELECT *
FROM Sales.ufn_MiniOrdersByCustomer(1);
GO

-- CROSS APPLY กับ Inline TVF
SELECT c.CustID, c.CompanyName, o.OrderID, o.Status
FROM Sales.MiniCustomers AS c
CROSS APPLY Sales.ufn_MiniOrdersByCustomer(c.CustID) AS o;
GO

/* --------------------------------------------------------------------------
   3) Multi-statement TVF — ประกาศ @table แล้ว INSERT ทีละขั้น
   -------------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION Sales.ufn_MiniOrderSummary_mstvf
(
    @CustID int
)
RETURNS @result TABLE
(
    OrderID   int NOT NULL,
    LineCount int NOT NULL,
    Freight   money NOT NULL,
    Status    varchar(20) NOT NULL
)
AS
BEGIN
    INSERT INTO @result (OrderID, LineCount, Freight, Status)
    SELECT
        o.OrderID,
        COUNT(d.ProductID),
        o.Freight,
        o.Status
    FROM Sales.MiniOrders AS o
    LEFT JOIN Sales.MiniOrderDetails AS d
        ON d.OrderID = o.OrderID
    WHERE o.CustID = @CustID
    GROUP BY o.OrderID, o.Freight, o.Status;

    RETURN;
END;
GO

SELECT * FROM Sales.ufn_MiniOrderSummary_mstvf(1);
GO

/* --------------------------------------------------------------------------
   4) Performance impact — Scalar & mTVF vs Inline / JOIN
   ใช้ AdventureWorks Sales.SalesOrderHeader / Detail เพื่อให้มีปริมาณข้อมูล
   Instructor: เปิด Actual Plan + สังเกต STATISTICS
   -------------------------------------------------------------------------- */
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- 4a) Scalar UDF ใน SELECT list (อาจช้า / ไม่ parallel ดีในเวอร์ชันเก่า)
CREATE OR ALTER FUNCTION Sales.ufn_OrderFreightBucket
(
    @Freight money
)
RETURNS varchar(10)
AS
BEGIN
    DECLARE @b varchar(10);
    SET @b = CASE
        WHEN @Freight < 50 THEN 'LOW'
        WHEN @Freight < 200 THEN 'MID'
        ELSE 'HIGH'
    END;
    RETURN @b;
END;
GO

PRINT N'--- Scalar UDF over many rows ---';
SELECT TOP (5000)
    h.SalesOrderID,
    h.Freight,
    Sales.ufn_OrderFreightBucket(h.Freight) AS Bucket
FROM Sales.SalesOrderHeader AS h;
GO

PRINT N'--- Equivalent CASE expression (no UDF) ---';
SELECT TOP (5000)
    h.SalesOrderID,
    h.Freight,
    CASE
        WHEN h.Freight < 50 THEN 'LOW'
        WHEN h.Freight < 200 THEN 'MID'
        ELSE 'HIGH'
    END AS Bucket
FROM Sales.SalesOrderHeader AS h;
GO

-- 4b) Inline TVF vs Multi-statement TVF (pattern เดียวกัน)
CREATE OR ALTER FUNCTION Production.ufn_ProductsByColor_Inline
(
    @Color nvarchar(15)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ProductID, Name, ProductNumber, ListPrice, Color
    FROM Production.Product
    WHERE Color = @Color
);
GO

CREATE OR ALTER FUNCTION Production.ufn_ProductsByColor_mstvf
(
    @Color nvarchar(15)
)
RETURNS @t TABLE
(
    ProductID     int NOT NULL,
    Name          nvarchar(50) NOT NULL,
    ProductNumber nvarchar(25) NOT NULL,
    ListPrice     money NOT NULL,
    Color         nvarchar(15) NULL
)
AS
BEGIN
    INSERT INTO @t (ProductID, Name, ProductNumber, ListPrice, Color)
    SELECT ProductID, Name, ProductNumber, ListPrice, Color
    FROM Production.Product
    WHERE Color = @Color;

    RETURN;
END;
GO

PRINT N'--- Inline TVF ---';
SELECT COUNT(*) AS Cnt
FROM Production.ufn_ProductsByColor_Inline(N'Black') AS p
INNER JOIN Sales.SalesOrderDetail AS d ON d.ProductID = p.ProductID;
GO

PRINT N'--- Multi-statement TVF ---';
SELECT COUNT(*) AS Cnt
FROM Production.ufn_ProductsByColor_mstvf(N'Black') AS p
INNER JOIN Sales.SalesOrderDetail AS d ON d.ProductID = p.ProductID;
GO

/*
  จุดสังเกต Estimated/Actual Plan:
  - Inline: predicate มักถูก push / join กับ SalesOrderDetail ได้ดี
  - mTVF: มักประมาณ cardinality ของ @table ต่ำ → plan อาจไม่เหมาะสม
*/

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* --------------------------------------------------------------------------
   5) Alternatives สรุปสั้น ๆ
   - Inline TVF แทน Scalar เมื่อต้องการชุดคอลัมน์
   - JOIN / APPLY แทนการเรียก UDF ต่อแถว
   - Computed column (persisted) สำหรับสูตรคงที่บนตารางจริง
   -------------------------------------------------------------------------- */
-- ตัวอย่าง APPLY แทน scalar ต่อแถว
SELECT TOP (20)
    h.SalesOrderID,
    h.Freight,
    b.Bucket
FROM Sales.SalesOrderHeader AS h
CROSS APPLY
(
    SELECT CASE
        WHEN h.Freight < 50 THEN 'LOW'
        WHEN h.Freight < 200 THEN 'MID'
        ELSE 'HIGH'
    END AS Bucket
) AS b;
GO

/* --------------------------------------------------------------------------
   6) Security context (brief)
   Function อยู่ภายใต้ ownership chaining เหมือน procedure
   ผู้เรียกที่มีสิทธิ์บน function อาจอ่านตารางของเจ้าของ schema ได้โดยไม่ต้อง GRANT ตรง
   ไม่สามารถใช้ Function เป็นที่ซ่อน side-effect การเขียนข้อมูลได้
   -------------------------------------------------------------------------- */
PRINT N'Security: GRANT EXECUTE/SELECT on function modules; avoid hiding writes in UDFs.';
GO

PRINT N'=== Lab 06 Demo complete ===';
GO
