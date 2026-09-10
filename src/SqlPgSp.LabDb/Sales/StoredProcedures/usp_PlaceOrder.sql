CREATE PROCEDURE [Sales].[usp_PlaceOrder]
    @CustID               int,
    @ProductID            int,
    @Quantity             smallint,
    @UnitPrice            money,
    @Discount             numeric(4, 3) = 0,
    @PurchaseOrderNumber  varchar(25) = NULL,
    @Freight              money = 0,
    @OrderID              int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @OrderID = NULL;

    BEGIN TRY
        IF @Quantity IS NULL OR @Quantity <= 0
            THROW 51000, N'Quantity ต้องมากกว่า 0', 1;

        IF @UnitPrice IS NULL OR @UnitPrice < 0
            THROW 51000, N'UnitPrice ต้องไม่ติดลบ', 1;

        IF @Discount < 0 OR @Discount >= 1
            THROW 51000, N'Discount ต้องอยู่ในช่วง 0 ถึงน้อยกว่า 1', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [Sales].[MiniCustomers]
            WHERE [CustID] = @CustID
              AND [IsActive] = 1
        )
            THROW 51001, N'ไม่พบลูกค้าที่ใช้งานได้ (CustID)', 1;

        BEGIN TRANSACTION;

        DECLARE @stock int;

        SELECT @stock = p.[Quantity]
        FROM [Production].[MiniProducts] AS p WITH (UPDLOCK, ROWLOCK)
        WHERE p.[ProductID] = @ProductID;

        IF @stock IS NULL
            THROW 51003, N'ไม่พบ ProductID', 1;

        IF @stock < @Quantity
            THROW 51002, N'สินค้าไม่พอสำหรับจำนวนที่ขอ', 1;

        INSERT INTO [Sales].[MiniOrders] ([CustID], [PurchaseOrderNumber], [Freight], [Status])
        VALUES (@CustID, @PurchaseOrderNumber, @Freight, 'Open');

        SET @OrderID = CONVERT(int, SCOPE_IDENTITY());

        INSERT INTO [Sales].[MiniOrderDetails] ([OrderID], [ProductID], [UnitPrice], [Quantity], [Discount])
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

        UPDATE [Production].[MiniProducts]
        SET [Quantity] = [Quantity] - @Quantity
        WHERE [ProductID] = @ProductID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        EXEC [dbo].[usp_LogError];
        THROW;
    END CATCH
END;
GO
