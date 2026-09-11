/*
==============================================================================
 Lab 06 — Functions | Solutions
 Database: AdventureWorks / AdventureWorks2022
==============================================================================
*/
USE AdventureWorks;
GO

/* Exercise 1 */
CREATE OR ALTER FUNCTION Production.ufn_MiniProductQty
(
    @ProductID int
)
RETURNS int
AS
BEGIN
    DECLARE @qty int;

    SELECT @qty = p.Quantity
    FROM Production.MiniProducts AS p
    WHERE p.ProductID = @ProductID;

    RETURN @qty;
END;
GO

SELECT Production.ufn_MiniProductQty(854) AS Qty854;
GO

/* Exercise 2 */
CREATE OR ALTER FUNCTION Sales.ufn_MiniCustomerOrders
(
    @CustID int
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        o.Freight
    FROM Sales.MiniOrders AS o
    WHERE o.CustID = @CustID
);
GO

SELECT c.CustID, c.CompanyName, o.OrderID, o.Status, o.Freight
FROM Sales.MiniCustomers AS c
CROSS APPLY Sales.ufn_MiniCustomerOrders(c.CustID) AS o;
GO

/* Exercise 3 */
CREATE OR ALTER FUNCTION Sales.ufn_OpenOrders_mstvf()
RETURNS @t TABLE
(
    OrderID   int NOT NULL,
    CustID    int NULL,
    OrderDate datetime NOT NULL,
    Freight   money NOT NULL
)
AS
BEGIN
    INSERT INTO @t (OrderID, CustID, OrderDate, Freight)
    SELECT o.OrderID, o.CustID, o.OrderDate, o.Freight
    FROM Sales.MiniOrders AS o
    WHERE o.Status = 'Open';

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION Sales.ufn_OpenOrders_inline()
RETURNS TABLE
AS
RETURN
(
    SELECT o.OrderID, o.CustID, o.OrderDate, o.Freight
    FROM Sales.MiniOrders AS o
    WHERE o.Status = 'Open'
);
GO

/*
  ควรใช้ Inline เป็นค่าเริ่มต้น:
  - optimizer expand ได้ → cardinality / join ดีกว่า
  - mTVF ใช้เมื่อ logic หลายขั้นตอนที่เขียนเป็น single query ไม่ได้จริง ๆ
*/
SELECT * FROM Sales.ufn_OpenOrders_inline();
SELECT * FROM Sales.ufn_OpenOrders_mstvf();
GO

/* Exercise 4 */
SELECT TOP (100)
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

/* Exercise 5 — Deterministic vs Nondeterministic (สไลด์ 80) */
PRINT N'Deterministic: อินพุตเดิม → ผลเดิมเสมอ เช่น ABS(@x), หรือ UDF คำนวณจากพารามิเตอร์อย่างเดียว';
PRINT N'Nondeterministic: ผลอาจเปลี่ยนแม้พารามิเตอร์เดิม เช่น GETDATE(), NEWID(), UDF ที่อ่านตารางที่เปลี่ยนได้';
PRINT N'Indexed view / persisted computed มักต้องการ deterministic เพื่อให้เก็บผลซ้ำได้อย่างถูกต้อง';
GO
