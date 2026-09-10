/*
==============================================================================
 Workshop Day 1 — Order Processing | STARTER (incomplete)
 Database: AdventureWorks / AdventureWorks2022
 Prerequisite: setup/01-create-lab-objects.sql

 Goal: Implement Sales.usp_PlaceOrder as an atomic place-order API.
==============================================================================
*/
USE AdventureWorks;
GO

/* --------------------------------------------------------------------------
   Helper: usp_LogError (สร้างถ้ายังไม่มี)
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_LogError
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ErrorLog
    (
        UserName, ErrorNumber, ErrorSeverity, ErrorState,
        ErrorProcedure, ErrorLine, ErrorMessage, XactState
    )
    VALUES
    (
        SUSER_SNAME(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
        ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), XACT_STATE()
    );
END;
GO

/* --------------------------------------------------------------------------
   TODO: Implement Sales.usp_PlaceOrder
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrder
    @CustID    int,
    @ProductID int,
    @Quantity  smallint,
    @UnitPrice money,
    @OrderID   int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- TODO: SET XACT_ABORT ...

    BEGIN TRY
        -- TODO: validate @Quantity > 0
        -- TODO: validate customer exists + IsActive = 1  (THROW 51001)
        -- TODO: BEGIN TRAN
        -- TODO: check stock (THROW 51002 if insufficient)
        -- TODO: INSERT MiniOrders
        -- TODO: capture @OrderID
        -- TODO: INSERT MiniOrderDetails
        -- TODO: UPDATE MiniProducts SET Quantity -= @Quantity
        -- TODO: COMMIT TRAN

        RAISERROR(N'usp_PlaceOrder is not implemented yet.', 16, 1);
    END TRY
    BEGIN CATCH
        -- TODO: rollback if needed
        -- TODO: EXEC dbo.usp_LogError;
        -- TODO: THROW;
        THROW;
    END CATCH
END;
GO

/* --------------------------------------------------------------------------
   Test harness — รันหลัง implement
   -------------------------------------------------------------------------- */
DECLARE @newOrderId int;

-- Expect success
BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = 1,
        @ProductID = 854,
        @Quantity = 2,
        @UnitPrice = 100.00,
        @OrderID = @newOrderId OUTPUT;

    SELECT @newOrderId AS NewOrderId, N'SUCCESS' AS Result;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg, N'FAILED' AS Result;
END CATCH;
GO

-- Expect failure: bad customer
DECLARE @newOrderId int;
BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = -1,
        @ProductID = 854,
        @Quantity = 1,
        @UnitPrice = 10.00,
        @OrderID = @newOrderId OUTPUT;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH;
GO

-- Expect failure: excessive qty (should not leave orphan order)
DECLARE @newOrderId int;
DECLARE @qtyBefore int =
(
    SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 860
);

BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = 1,
        @ProductID = 860,
        @Quantity = 9999,
        @UnitPrice = 10.00,
        @OrderID = @newOrderId OUTPUT;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

SELECT
    @qtyBefore AS QtyBefore,
    (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 860) AS QtyAfter,
    (SELECT COUNT(*) FROM dbo.ErrorLog) AS ErrorLogRows;
GO
