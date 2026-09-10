/*
================================================================================
  Lab 03 — solution.sql
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

UPDATE Production.MiniProducts
SET Quantity = CASE ProductID
                 WHEN 854 THEN 100
                 WHEN 859 THEN 50
                 WHEN 860 THEN 50
               END
WHERE ProductID IN (854, 859, 860);
GO

/*------------------------------------------------------------------------------
  TODO 1
------------------------------------------------------------------------------*/
BEGIN TRANSACTION;
    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 5
    WHERE ProductID = 859;
COMMIT TRANSACTION;

BEGIN TRANSACTION;
    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 5
    WHERE ProductID = 859;
ROLLBACK TRANSACTION;

SELECT ProductID, Quantity
FROM Production.MiniProducts
WHERE ProductID = 859;  -- คาดหวัง 95
GO

/*------------------------------------------------------------------------------
  TODO 2 — atomic success
------------------------------------------------------------------------------*/
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        DECLARE @OrderID INT;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
        VALUES (2, N'EX-TODO2', GETDATE(), 10.00);
        SET @OrderID = SCOPE_IDENTITY();

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES
            (@OrderID, 854, 27, 10, 0),
            (@OrderID, 860, 19, 5,  0);

        UPDATE Production.MiniProducts SET Quantity = Quantity - 10 WHERE ProductID = 854;
        UPDATE Production.MiniProducts SET Quantity = Quantity - 5  WHERE ProductID = 860;

        COMMIT TRANSACTION;
        PRINT N'TODO2 committed';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH
SET XACT_ABORT OFF;
GO

SELECT o.OrderID, o.PurchaseOrderNumber, d.ProductID, d.Quantity
FROM Sales.MiniOrders AS o
JOIN Sales.MiniOrderDetails AS d ON d.OrderID = o.OrderID
WHERE o.PurchaseOrderNumber = N'EX-TODO2';
GO

/*------------------------------------------------------------------------------
  TODO 3 — oversell → rollback
------------------------------------------------------------------------------*/
DECLARE @QtyBefore INT =
(
    SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854
);

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        DECLARE @BadOrderID INT;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, OrderDate, Freight)
        VALUES (2, N'EX-TODO3', GETDATE(), 10.00);
        SET @BadOrderID = SCOPE_IDENTITY();

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES (@BadOrderID, 854, 27, 1, 0);

        UPDATE Production.MiniProducts
        SET Quantity = Quantity - 100000
        WHERE ProductID = 854;

        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT(N'TODO3 expected failure: ', ERROR_MESSAGE());
END CATCH
SET XACT_ABORT OFF;

SELECT * FROM Sales.MiniOrders WHERE PurchaseOrderNumber = N'EX-TODO3';

SELECT
    @QtyBefore AS QtyBefore,
    Quantity AS QtyAfter
FROM Production.MiniProducts
WHERE ProductID = 854;
GO

/*------------------------------------------------------------------------------
  TODO 4 — nested @@TRANCOUNT
------------------------------------------------------------------------------*/
BEGIN TRANSACTION;
    PRINT CONCAT(N'After outer BEGIN: ', @@TRANCOUNT);

    UPDATE Production.MiniProducts
    SET Quantity = Quantity - 1
    WHERE ProductID = 860;

    BEGIN TRANSACTION;
        PRINT CONCAT(N'After inner BEGIN: ', @@TRANCOUNT);
        UPDATE Production.MiniProducts
        SET Quantity = Quantity - 1
        WHERE ProductID = 860;
    COMMIT TRANSACTION;
    PRINT CONCAT(N'After inner COMMIT: ', @@TRANCOUNT);
    PRINT N'Inner COMMIT แค่ลด @@TRANCOUNT — ยังไม่ persist จริงจนกว่า outer จะ COMMIT';

ROLLBACK TRANSACTION;
PRINT CONCAT(N'After outer ROLLBACK: ', @@TRANCOUNT);
PRINT N'ROLLBACK ชั้นนอกยกเลิกงานทั้งหมด รวมที่ทำในชั้นใน';

SELECT ProductID, Quantity
FROM Production.MiniProducts
WHERE ProductID = 860;
GO

PRINT N'===== Lab 03 solution ครบ =====';
GO
