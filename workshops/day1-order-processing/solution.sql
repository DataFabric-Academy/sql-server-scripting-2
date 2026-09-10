/*
==============================================================================
 Workshop Day 1 — Order Processing | SOLUTION
 Database: AdventureWorks / AdventureWorks2022
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

CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrder
    @CustID    int,
    @ProductID int,
    @Quantity  smallint,
    @UnitPrice money,
    @OrderID   int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @OrderID = NULL;

    BEGIN TRY
        IF @Quantity IS NULL OR @Quantity <= 0
            THROW 51000, N'Quantity must be greater than zero.', 1;

        IF @UnitPrice IS NULL OR @UnitPrice < 0
            THROW 51000, N'UnitPrice must be >= 0.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Sales.MiniCustomers AS c
            WHERE c.CustID = @CustID
              AND c.IsActive = 1
        )
            THROW 51001, N'Customer not found or inactive.', 1;

        BEGIN TRAN;

        DECLARE @stock int;

        SELECT @stock = p.Quantity
        FROM Production.MiniProducts AS p WITH (UPDLOCK, ROWLOCK)
        WHERE p.ProductID = @ProductID;

        IF @stock IS NULL
            THROW 51003, N'Product not found.', 1;

        IF @stock < @Quantity
            THROW 51002, N'Insufficient stock for requested quantity.', 1;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
        VALUES (@CustID, NULL, 0, 'Open');

        SET @OrderID = SCOPE_IDENTITY();

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, 0);

        UPDATE Production.MiniProducts
        SET Quantity = Quantity - @Quantity
        WHERE ProductID = @ProductID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        EXEC dbo.usp_LogError;

        THROW;
    END CATCH
END;
GO

/* --- Verification --- */
DECLARE @newOrderId int;

EXEC Sales.usp_PlaceOrder
    @CustID = 1,
    @ProductID = 854,
    @Quantity = 2,
    @UnitPrice = 100.00,
    @OrderID = @newOrderId OUTPUT;

SELECT
    o.OrderID,
    o.CustID,
    o.Status,
    d.ProductID,
    d.Quantity,
    d.UnitPrice,
    p.Quantity AS RemainingStock
FROM Sales.MiniOrders AS o
INNER JOIN Sales.MiniOrderDetails AS d ON d.OrderID = o.OrderID
INNER JOIN Production.MiniProducts AS p ON p.ProductID = d.ProductID
WHERE o.OrderID = @newOrderId;
GO

-- Failure path
BEGIN TRY
    DECLARE @id int;
    EXEC Sales.usp_PlaceOrder
        @CustID = 1,
        @ProductID = 860,
        @Quantity = 9999,
        @UnitPrice = 1,
        @OrderID = @id OUTPUT;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

SELECT TOP (3) * FROM dbo.ErrorLog ORDER BY ErrorLogID DESC;
GO
