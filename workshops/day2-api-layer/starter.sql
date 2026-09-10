/*
==============================================================================
 Workshop Day 2 — API Layer | STARTER (incomplete)
 Database: AdventureWorks / AdventureWorks2022
 Prerequisite: setup/01-create-lab-objects.sql, Workshop Day 1
==============================================================================
*/
USE AdventureWorks;
GO

/* --------------------------------------------------------------------------
   1) Error logger
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
   2) TODO: Sales.usp_CreateCustomer
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_CreateCustomer
    @CompanyName  nvarchar(40),
    @ContactName  nvarchar(30),
    @ContactTitle nvarchar(30),
    @Address      nvarchar(60),
    @City         nvarchar(15),
    @Country      nvarchar(15),
    @Phone        nvarchar(24),
    @Region       nvarchar(15) = NULL,
    @PostalCode   nvarchar(10) = NULL,
    @CustID       int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- TODO: validate required strings are not blank
        -- TODO: INSERT into Sales.MiniCustomers
        -- TODO: SET @CustID = SCOPE_IDENTITY()
        THROW 59999, N'TODO: implement usp_CreateCustomer', 1;
    END TRY
    BEGIN CATCH
        -- TODO: EXEC dbo.usp_LogError; then THROW;
        THROW;
    END CATCH
END;
GO

/* --------------------------------------------------------------------------
   3) TODO: refine Sales.usp_PlaceOrder (atomic + ErrorLog)
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrder
    @CustID             int,
    @ProductID          int,
    @Quantity           smallint,
    @UnitPrice          money,
    @Discount           numeric(4, 3) = 0,
    @PurchaseOrderNumber varchar(25) = NULL,
    @Freight            money = 0,
    @OrderID            int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- TODO: validate customer / stock
        -- TODO: BEGIN TRAN → insert order + detail → decrement stock → COMMIT
        -- TODO: on failure: log + rollback + THROW
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
   4) TODO: Inline TVF Sales.ufn_GetCustomerOrderSummary
   -------------------------------------------------------------------------- */
/*
CREATE OR ALTER FUNCTION Sales.ufn_GetCustomerOrderSummary (@CustID int)
RETURNS TABLE
AS
RETURN
(
    -- TODO: OrderID, OrderDate, Status, LineCount, MerchandiseTotal, Freight
    SELECT 1 AS Placeholder WHERE 1 = 0
);
GO
*/

/* --------------------------------------------------------------------------
   5) TODO: Trigger — เลือกอย่างน้อย 1
   Option A: AFTER INSERT/UPDATE audit table
   Option B: INSTEAD OF DELETE → soft-delete (Status = 'Cancelled')
   -------------------------------------------------------------------------- */

/* --------------------------------------------------------------------------
   Smoke tests (ปลดคอมเมนต์เมื่อ implement แล้ว)
   -------------------------------------------------------------------------- */
/*
DECLARE @NewCust int, @NewOrder int;

EXEC Sales.usp_CreateCustomer
    @CompanyName = N'Test Co', @ContactName = N'Tee', @ContactTitle = N'Buyer',
    @Address = N'9 Expert Rd', @City = N'Bangkok', @Country = N'Thailand',
    @Phone = N'02-111-2222', @CustID = @NewCust OUTPUT;

SELECT @NewCust AS NewCustID;

EXEC Sales.usp_PlaceOrder
    @CustID = @NewCust, @ProductID = 854, @Quantity = 2, @UnitPrice = 100,
    @OrderID = @NewOrder OUTPUT;

SELECT @NewOrder AS NewOrderID;
SELECT * FROM Sales.ufn_GetCustomerOrderSummary(@NewCust);
*/
GO
