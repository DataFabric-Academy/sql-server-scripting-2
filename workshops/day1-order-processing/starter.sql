/*
==============================================================================
 Workshop Day 1 — Order Processing | STARTER
 Goal:
   1) Sales.usp_PlaceOrder (บรรทัดเดียว) — ใช้ OUTPUT INSERTED จับ OrderID
   2) (ขยาย) Sales.OrderLineType + Sales.usp_PlaceOrderLines (TVP หลายบรรทัด)
 แล้วรัน acceptance-tests.sql
==============================================================================
*/
USE AdventureWorks;
GO

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
   TODO A: usp_PlaceOrder (single line)
   - ใช้ DECLARE @NewOrders TABLE ...; INSERT ... OUTPUT inserted.OrderID INTO @NewOrders
   - ห้ามพึ่ง SCOPE_IDENTITY() เป็นคำตอบหลัก (ใช้ OUTPUT)
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
    -- TODO: SET XACT_ABORT ON;
    SET @OrderID = NULL;

    BEGIN TRY
        -- TODO: validate + BEGIN TRAN + stock check
        -- TODO: INSERT MiniOrders WITH OUTPUT INSERTED into table var → @OrderID
        -- TODO: INSERT detail + UPDATE stock + COMMIT
        THROW 59999, N'TODO: implement usp_PlaceOrder', 1;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        EXEC dbo.usp_LogError;
        THROW;
    END CATCH
END;
GO

/* --------------------------------------------------------------------------
   TODO B (ขยาย): TVP + usp_PlaceOrderLines
   -------------------------------------------------------------------------- */
/*
IF OBJECT_ID(N'Sales.usp_PlaceOrderLines', N'P') IS NOT NULL DROP PROCEDURE Sales.usp_PlaceOrderLines;
IF TYPE_ID(N'Sales.OrderLineType') IS NOT NULL DROP TYPE Sales.OrderLineType;
GO
CREATE TYPE Sales.OrderLineType AS TABLE
(
    ProductID int NOT NULL,
    Quantity  smallint NOT NULL,
    UnitPrice money NOT NULL,
    Discount  numeric(4,3) NOT NULL DEFAULT (0)
);
GO
CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrderLines
    @CustID int,
    @Lines Sales.OrderLineType READONLY,
    @PurchaseOrderNumber varchar(25) = NULL,
    @Freight money = 0,
    @OrderID int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- TODO: validate lines + customer + stock for all products
    -- TODO: INSERT order OUTPUT INSERTED; INSERT details FROM @Lines; UPDATE stock aggregated
    THROW 59999, N'TODO: implement usp_PlaceOrderLines', 1;
END;
GO
*/

PRINT N'Implement TODOs แล้วรัน acceptance-tests.sql';
GO
