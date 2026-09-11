/*
==============================================================================
 Workshop Day 1 — Order Processing | SOLUTION
 - usp_PlaceOrder (บรรทัดเดียว) ใช้ OUTPUT INSERTED
 - usp_PlaceOrderLines (หลายบรรทัด) ใช้ TVP Sales.OrderLineType
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

/* --- TVP สำหรับหลายบรรทัด --- */
IF OBJECT_ID(N'Sales.usp_PlaceOrderLines', N'P') IS NOT NULL
    DROP PROCEDURE Sales.usp_PlaceOrderLines;
IF OBJECT_ID(N'Sales.usp_SumOrderLines', N'P') IS NOT NULL
    DROP PROCEDURE Sales.usp_SumOrderLines;
IF OBJECT_ID(N'Sales.usp_PreviewOrderLines', N'P') IS NOT NULL
    DROP PROCEDURE Sales.usp_PreviewOrderLines;
IF TYPE_ID(N'Sales.OrderLineType') IS NOT NULL
    DROP TYPE Sales.OrderLineType;
GO

CREATE TYPE Sales.OrderLineType AS TABLE
(
    ProductID int NOT NULL,
    Quantity  smallint NOT NULL,
    UnitPrice money NOT NULL,
    Discount  numeric(4, 3) NOT NULL DEFAULT (0)
);
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

        DECLARE @NewOrders TABLE (OrderID int NOT NULL);

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
        OUTPUT inserted.OrderID INTO @NewOrders (OrderID)
        VALUES (@CustID, NULL, 0, 'Open');

        SELECT @OrderID = OrderID FROM @NewOrders;

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

CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrderLines
    @CustID              int,
    @Lines               Sales.OrderLineType READONLY,
    @PurchaseOrderNumber varchar(25) = NULL,
    @Freight             money = 0,
    @OrderID             int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @OrderID = NULL;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM @Lines)
            THROW 51000, N'Order must contain at least one line.', 1;

        IF EXISTS (SELECT 1 FROM @Lines WHERE Quantity IS NULL OR Quantity <= 0)
            THROW 51000, N'Each line Quantity must be > 0.', 1;

        IF EXISTS (SELECT 1 FROM @Lines WHERE UnitPrice IS NULL OR UnitPrice < 0)
            THROW 51000, N'Each line UnitPrice must be >= 0.', 1;

        IF EXISTS (SELECT 1 FROM @Lines WHERE Discount < 0 OR Discount >= 1)
            THROW 51000, N'Each line Discount must be in [0, 1).', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Sales.MiniCustomers AS c
            WHERE c.CustID = @CustID
              AND c.IsActive = 1
        )
            THROW 51001, N'Customer not found or inactive.', 1;

        BEGIN TRAN;

        /* ล็อกและตรวจสต็อกทุกบรรทัด */
        IF EXISTS
        (
            SELECT 1
            FROM @Lines AS l
            LEFT JOIN Production.MiniProducts AS p WITH (UPDLOCK, ROWLOCK)
                ON p.ProductID = l.ProductID
            GROUP BY l.ProductID
            HAVING MIN(CASE WHEN p.ProductID IS NULL THEN 0 ELSE 1 END) = 0
                OR SUM(l.Quantity) > MAX(p.Quantity)
        )
            THROW 51002, N'Insufficient stock or unknown ProductID in order lines.', 1;

        DECLARE @NewOrders TABLE (OrderID int NOT NULL);

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
        OUTPUT inserted.OrderID INTO @NewOrders (OrderID)
        VALUES (@CustID, @PurchaseOrderNumber, @Freight, 'Open');

        SELECT @OrderID = OrderID FROM @NewOrders;

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        SELECT @OrderID, ProductID, UnitPrice, Quantity, Discount
        FROM @Lines;

        UPDATE p
        SET p.Quantity = p.Quantity - x.QtySum
        FROM Production.MiniProducts AS p
        INNER JOIN
        (
            SELECT ProductID, SUM(Quantity) AS QtySum
            FROM @Lines
            GROUP BY ProductID
        ) AS x
            ON x.ProductID = p.ProductID;

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
