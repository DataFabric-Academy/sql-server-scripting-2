/*
================================================================================
  Lab 01 — demo.sql  (Instructor Demo)
  Language Elements & Scripting
================================================================================
  DB: AdventureWorks  (เปลี่ยนชื่อได้ถ้าใช้ AdventureWorks2022)
  รันทีละ section ตามลำดับ; อ่านคอมเมนต์ก่อน execute
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*==============================================================================
  SECTION A — Comments, Operators, Variables, Expressions
==============================================================================*/

-- Single-line comment
/*
   Multi-line comment
   ใช้จัดกลุ่ม demo / อธิบาย intent ของ batch
*/

DECLARE @UnitPrice   MONEY       = 19.99;
DECLARE @Qty         INT         = 5;
DECLARE @DiscountPct DECIMAL(4,3) = 0.10;  -- 10%
DECLARE @LineTotal   MONEY;

-- Expression: arithmetic + ใช้ตัวแปร
SET @LineTotal = @UnitPrice * @Qty * (1 - @DiscountPct);

SELECT
    @UnitPrice   AS UnitPrice,
    @Qty         AS Qty,
    @DiscountPct AS DiscountPct,
    @LineTotal   AS LineTotal,
    -- Comparison / logical (ผลเป็น bit ใน SELECT)
    CASE WHEN @LineTotal > 50 THEN 1 ELSE 0 END AS IsOverFifty;

-- CONCAT / string expression
DECLARE @ProductName NVARCHAR(50) = N'HL Road Frame';
SELECT CONCAT(@ProductName, N' x ', @Qty, N' = ', @LineTotal) AS SummaryText;
GO

/*==============================================================================
  SECTION B — Batch vs GO / Variable Scope
==============================================================================
  GO = batch separator ของ SSMS (ไม่ใช่คำสั่ง T-SQL บน server)
  ตัวแปรที่ DECLARE ใน batch หนึ่ง ใช้ใน batch ถัดไปไม่ได้
*/

DECLARE @BatchDemo INT = 100;
PRINT CONCAT(N'@BatchDemo ใน batch นี้ = ', @BatchDemo);
GO

-- บรรทัดถัดไปจะ ERROR ถ้า uncomment เพราะอยู่นอก scope ของ DECLARE ด้านบน
-- PRINT @BatchDemo;
PRINT N'หลัง GO: ตัวแปร @BatchDemo จาก batch ก่อนหน้าใช้ไม่ได้แล้ว';
GO

-- แสดงว่า CREATE/DDL มักแยก batch
IF OBJECT_ID(N'tempdb..#DemoScope') IS NOT NULL DROP TABLE #DemoScope;
GO
CREATE TABLE #DemoScope (Id INT NOT NULL);
GO
INSERT INTO #DemoScope (Id) VALUES (1), (2);
SELECT * FROM #DemoScope;  -- temp table ใช้ข้าม batch ใน session เดียวกันได้
GO

/*==============================================================================
  SECTION C — IF / ELSE
==============================================================================*/

DECLARE @HighValueCount INT =
(
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader
    WHERE TotalDue > 100000
);

IF @HighValueCount > 0
BEGIN
    PRINT CONCAT(N'พบออเดอร์มูลค่าสูงจำนวน ', @HighValueCount, N' รายการ');
END
ELSE
BEGIN
    PRINT N'ไม่พบออเดอร์มูลค่าสูงตามเงื่อนไข';
END
GO

-- IF EXISTS — pattern ที่ใช้บ่อยก่อน INSERT/UPDATE
IF EXISTS
(
    SELECT 1
    FROM Production.Product
    WHERE ProductNumber = N'BK-M82B-44'
)
    PRINT N'พบสินค้า BK-M82B-44';
ELSE
    PRINT N'ไม่พบสินค้า';
GO

/*==============================================================================
  SECTION D — WHILE + CONTINUE + BREAK
==============================================================================*/

DECLARE @i INT = 0;

WHILE @i < 10
BEGIN
    SET @i += 1;

    -- ข้ามเลขคู่
    IF @i % 2 = 0
        CONTINUE;

    -- หยุดเมื่อถึง 7
    IF @i >= 7
        BREAK;

    PRINT CONCAT(N'odd i = ', @i);
END

PRINT N'ออกจาก WHILE แล้ว';
GO

/*==============================================================================
  SECTION E — Table Variable vs Temp Table
==============================================================================
  เปิด Include Actual Execution Plan แล้วรันทั้งสองบล็อกเปรียบเทียบ
*/

-- E1) Table variable
DECLARE @Orders TABLE
(
    SalesOrderID INT NOT NULL PRIMARY KEY,
    CustomerID   INT NOT NULL,
    TotalDue     MONEY NOT NULL
);

INSERT INTO @Orders (SalesOrderID, CustomerID, TotalDue)
SELECT TOP (500) SalesOrderID, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;

SELECT AVG(TotalDue) AS AvgDue_TableVar
FROM @Orders;
-- สังเกต: ประมาณจำนวนแถวใน plan มักต่ำกว่าความจริง (โดยเฉพาะแผนเก่า)
GO

-- E2) Temp table
IF OBJECT_ID(N'tempdb..#Orders') IS NOT NULL DROP TABLE #Orders;

CREATE TABLE #Orders
(
    SalesOrderID INT NOT NULL PRIMARY KEY,
    CustomerID   INT NOT NULL,
    TotalDue     MONEY NOT NULL
);

INSERT INTO #Orders (SalesOrderID, CustomerID, TotalDue)
SELECT TOP (500) SalesOrderID, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;

-- temp table มีสถิติ → optimizer ประมาณแถวได้ดีกว่า
SELECT AVG(TotalDue) AS AvgDue_TempTable
FROM #Orders;

DROP TABLE #Orders;
GO

/*==============================================================================
  SECTION F — Predicate Pitfalls: = NULL
==============================================================================*/

PRINT N'--- ผิด: = NULL (ได้ 0 แถวเสมอ เพราะผลเปรียบเทียบเป็น UNKNOWN) ---';
SELECT TOP (5) BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE MiddleName = NULL;

PRINT N'--- ถูก: IS NULL ---';
SELECT TOP (5) BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE MiddleName IS NULL;

PRINT N'--- IS NOT NULL ---';
SELECT TOP (5) BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE MiddleName IS NOT NULL;
GO

/*==============================================================================
  SECTION G — Mini* quick touch (ยืนยัน setup)
==============================================================================*/

SELECT ProductID, ProductName, Quantity
FROM Production.MiniProducts
WHERE ProductID IN (854, 859, 860);

SELECT CustID, CompanyName, ContactName
FROM Sales.MiniCustomers;
GO

/*==============================================================================
  SECTION H — SQL Server 2025 optional: Native REGEXP (compat 170)
  ข้ามได้ถ้า engine < 2025 หรือ compatibility_level < 170
  เอกสาร: https://devblogs.microsoft.com/azure-sql/unlocking-the-power-of-regex-in-sql-server/
==============================================================================*/
IF EXISTS
(
    SELECT 1
    FROM sys.databases
    WHERE name = DB_NAME()
      AND compatibility_level >= 170
)
BEGIN
    -- ตัวอย่างสั้น: ตรวจรูปแบบเบอร์โทรแบบง่าย
    SELECT
        CustID,
        Phone,
        CASE WHEN REGEXP_LIKE(Phone, N'^\([0-9]{2,3}\)[ ]?[0-9\-]+$') THEN 1 ELSE 0 END AS LooksLikePhone
    FROM Sales.MiniCustomers;
END
ELSE
    PRINT N'Skip REGEXP demo — ต้องการ SQL Server 2025 + compatibility_level >= 170';
GO

PRINT N'===== Lab 01 demo เสร็จสิ้น =====';
GO
