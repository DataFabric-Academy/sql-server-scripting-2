/*
================================================================================
  Lab 03 — demo.sql  (Instructor Demo)
  Transactions
================================================================================
  DB: AdventureWorks + Mini* objects จาก setup
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/* รีเซ็ตสต็อกสำหรับ demo ให้ผลลัพธ์ทำซ้ำได้ */
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID
                 WHEN 854 THEN 100
                 WHEN 859 THEN 50
                 WHEN 860 THEN 50
               END
WHERE ProductID IN (854, 859, 860);
GO

/*==============================================================================
  SECTION A — Transaction คืออะไร / Autocommit
==============================================================================
  โดย default SQL Server ใช้ autocommit:
  แต่ละ statement สำเร็จ → commit อัตโนมัติ, ล้ม → rollback statement นั้น
*/

SELECT @@TRANCOUNT AS TranCount_ShouldBe0;

-- Implicit / autocommit ตัวอย่าง (ไม่มี BEGIN TRAN)
UPDATE Production.MiniProducts
SET Quantity = Quantity  -- no-op เพื่อโชว์ว่า statement เดียวจบในตัว
WHERE ProductID = 854;

SELECT @@TRANCOUNT AS Still0;
GO

/*==============================================================================
  SECTION B — Explicit BEGIN / COMMIT / ROLLBACK
==============================================================================*/

BEGIN TRANSACTION;
    SELECT @@TRANCOUNT AS AfterBegin;  -- 1

    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 1
    WHERE ProductID = 854;

    SELECT ProductID, Quantity FROM Production.MiniProducts WHERE ProductID = 854;

ROLLBACK TRANSACTION;  -- ยกเลิกทั้งหมดใน tran
SELECT @@TRANCOUNT AS AfterRollback; -- 0

SELECT ProductID, Quantity
FROM Production.MiniProducts
WHERE ProductID = 854;  -- กลับค่าเดิม
GO

BEGIN TRANSACTION;
    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 1
    WHERE ProductID = 854;
COMMIT TRANSACTION;

SELECT ProductID, Quantity
FROM Production.MiniProducts
WHERE ProductID = 854;  -- ติด -1 จากค่าหลัง reset
GO

-- คืนค่า
UPDATE Production.MiniProducts SET Quantity = 100 WHERE ProductID = 854;
GO

/*==============================================================================
  SECTION C — Nesting และ @@TRANCOUNT
==============================================================================*/

BEGIN TRANSACTION;                 -- @@TRANCOUNT = 1
    BEGIN TRANSACTION;             -- @@TRANCOUNT = 2
        SELECT @@TRANCOUNT AS NestedCount;
    COMMIT TRANSACTION;            -- @@TRANCOUNT = 1  (ยังไม่ commit จริงทั้งก้อน)
    SELECT @@TRANCOUNT AS AfterInnerCommit;
ROLLBACK TRANSACTION;              -- ยกเลิกทั้งหมด → 0
SELECT @@TRANCOUNT AS AfterOuterRollback;
GO

/*==============================================================================
  SECTION D — Error โดยไม่มี XACT_ABORT (พฤติกรรมอันตราย)
==============================================================================
  ทำให้ Quantity ติดลบผ่าน CHECK → statement ล้ม
  สังเกตว่า transaction อาจยังเปิดอยู่ และงานก่อนหน้าใน batch อาจค้าง
*/

BEGIN TRANSACTION;
    INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
    VALUES (1, N'DEMO-NO-XACTABORT', GETDATE(), 1.00);

    DECLARE @Oid INT = SCOPE_IDENTITY();

    -- พยายามตัดสต็อกเกิน → ชน CK_MiniProducts_Quantity
    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 100000
    WHERE ProductID = 854;

    -- ถ้ามาถึงตรงนี้ แสดงว่า UPDATE ไม่ล้ม (ไม่ควร)
    INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@Oid, 854, 27, 1, 0);

COMMIT TRANSACTION;
GO

-- ตรวจสภาพหลัง error
SELECT @@TRANCOUNT AS TranCount_Check;
SELECT TOP (5) OrderID, PurchaseOrderNumber
FROM Sales.MiniOrders
ORDER BY OrderID DESC;

-- ถ้ายังมี transaction ค้าง ให้ rollback มือ
IF @@TRANCOUNT > 0
BEGIN
    PRINT N'ยังมี transaction ค้าง — ROLLBACK เพื่อเคลียร์ session';
    ROLLBACK TRANSACTION;
END
GO

/* ลบ order demo ที่ค้างถ้ามี (กรณี commit ไปแล้วบางส่วนตามพฤติกรรม) */
DELETE FROM Sales.MiniOrderDetails
WHERE OrderID IN (SELECT OrderID FROM Sales.MiniOrders WHERE PurchaseOrderNumber = N'DEMO-NO-XACTABORT');
DELETE FROM Sales.MiniOrders WHERE PurchaseOrderNumber = N'DEMO-NO-XACTABORT';
UPDATE Production.MiniProducts SET Quantity = 100 WHERE ProductID = 854;
GO

/*==============================================================================
  SECTION E — SET XACT_ABORT ON
==============================================================================
  เมื่อ error เกิดขึ้น → abort ทั้ง batch และ rollback transaction อัตโนมัติ
*/

SET XACT_ABORT ON;
BEGIN TRANSACTION;
    INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
    VALUES (1, N'DEMO-XACTABORT', GETDATE(), 1.00);

    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 100000  -- จะล้ม + rollback ทั้ง tran
    WHERE ProductID = 854;

COMMIT TRANSACTION;
SET XACT_ABORT OFF;
GO

SELECT @@TRANCOUNT AS ShouldBe0;
SELECT * FROM Sales.MiniOrders WHERE PurchaseOrderNumber = N'DEMO-XACTABORT'; -- ว่าง
SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854; -- ไม่โดนหัก
GO

/*==============================================================================
  SECTION F — TRY/CATCH + XACT_STATE()  (แพทเทิร์นแนะนำ)
==============================================================================
  XACT_STATE():
     1  = active, committable
     0  = no transaction
    -1  = uncommittable (ต้อง ROLLBACK)
*/

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        DECLARE @CustID INT = 1;
        DECLARE @OrderID INT;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
        VALUES (@CustID, N'DEMO-TRYCATCH', GETDATE(), 32.38);
        SET @OrderID = SCOPE_IDENTITY();

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES
            (@OrderID, 854, 27, 30, 0.20),
            (@OrderID, 859, 97, 2,  0.00),
            (@OrderID, 860, 19, 3,  0.00);

        UPDATE Production.MiniProducts SET Quantity = Quantity - 30 WHERE ProductID = 854;
        UPDATE Production.MiniProducts SET Quantity = Quantity - 2  WHERE ProductID = 859;
        UPDATE Production.MiniProducts SET Quantity = Quantity - 3  WHERE ProductID = 860;

        -- สมมติ business rule: ถ้าไม่มี PO และยอดสูง ให้ยกเลิก
        -- (ตัวอย่างนี้ commit ตามปกติ — ดู exercise สำหรับเคส rollback)

        COMMIT TRANSACTION;
        PRINT N'Order committed.';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Error: ', ERROR_MESSAGE());
    PRINT CONCAT(N'XACT_STATE=', XACT_STATE(), N' @@TRANCOUNT=', @@TRANCOUNT);

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    -- optional: INSERT dbo.ErrorLog …
    THROW;
END CATCH
SET XACT_ABORT OFF;
GO

SELECT o.OrderID, o.PurchaseOrderNumber, d.ProductID, d.Quantity
FROM Sales.MiniOrders AS o
JOIN Sales.MiniOrderDetails AS d ON d.OrderID = o.OrderID
WHERE o.PurchaseOrderNumber = N'DEMO-TRYCATCH';

SELECT ProductID, Quantity
FROM Production.MiniProducts
WHERE ProductID IN (854, 859, 860);
GO

/*==============================================================================
  SECTION G — เคจที่ชน CHECK เพื่อโชว์ rollback ทั้งชุด
==============================================================================*/

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
        VALUES (1, N'DEMO-OVERSELL', GETDATE(), 5.00);
        DECLARE @BadOrder INT = SCOPE_IDENTITY();

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES (@BadOrder, 854, 27, 1, 0);

        -- ตัดเกินสต็อก → CHECK fail → ทั้ง order ต้องหายหลัง ROLLBACK
        UPDATE Production.MiniProducts
        SET Quantity = Quantity - 100000
        WHERE ProductID = 854;

        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()  AS ErrNo,
        ERROR_MESSAGE() AS ErrMsg,
        XACT_STATE()    AS XactStateAfterHandler;
END CATCH
SET XACT_ABORT OFF;
GO

SELECT * FROM Sales.MiniOrders WHERE PurchaseOrderNumber = N'DEMO-OVERSELL'; -- ว่าง
SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854;
GO

PRINT N'===== Lab 03 demo เสร็จสิ้น =====';
GO
