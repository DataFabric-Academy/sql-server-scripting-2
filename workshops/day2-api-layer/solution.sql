/*
==============================================================================
 Workshop Day 2 — API Layer | SOLUTION
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

/* --------------------------------------------------------------------------
   usp_CreateCustomer
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
-- WITH EXECUTE AS OWNER  -- เปิดใช้ถ้าต้องการ elevate ข้าม DENY ของ caller
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@CompanyName)), N'') IS NULL
            OR NULLIF(LTRIM(RTRIM(@ContactName)), N'') IS NULL
            OR NULLIF(LTRIM(RTRIM(@Phone)), N'') IS NULL
        BEGIN
            THROW 52001, N'CompanyName, ContactName และ Phone ต้องไม่ว่าง', 1;
        END;

        INSERT INTO Sales.MiniCustomers
        (
            CompanyName, ContactName, ContactTitle, Address,
            City, Region, PostalCode, Country, Phone
        )
        VALUES
        (
            @CompanyName, @ContactName, @ContactTitle, @Address,
            @City, @Region, @PostalCode, @Country, @Phone
        );

        SET @CustID = CONVERT(int, SCOPE_IDENTITY());
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        EXEC dbo.usp_LogError;
        THROW;
    END CATCH
END;
GO

/* --------------------------------------------------------------------------
   usp_PlaceOrder
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_PlaceOrder
    @CustID              int,
    @ProductID           int,
    @Quantity            smallint,
    @UnitPrice           money,
    @Discount            numeric(4, 3) = 0,
    @PurchaseOrderNumber varchar(25) = NULL,
    @Freight             money = 0,
    @OrderID             int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @Quantity IS NULL OR @Quantity <= 0
            THROW 51000, N'Quantity ต้องมากกว่า 0', 1;

        IF @UnitPrice IS NULL OR @UnitPrice < 0
            THROW 51000, N'UnitPrice ต้องไม่ติดลบ', 1;

        IF @Discount < 0 OR @Discount >= 1
            THROW 51000, N'Discount ต้องอยู่ในช่วง 0 ถึงน้อยกว่า 1', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Sales.MiniCustomers
            WHERE CustID = @CustID AND IsActive = 1
        )
            THROW 51001, N'ไม่พบลูกค้าที่ใช้งานได้ (CustID)', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Production.MiniProducts
            WHERE ProductID = @ProductID AND Quantity >= @Quantity
        )
            THROW 51002, N'สินค้าไม่พอหรือไม่พบ ProductID', 1;

        BEGIN TRANSACTION;

        INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
        VALUES (@CustID, @PurchaseOrderNumber, @Freight, 'Open');

        SET @OrderID = CONVERT(int, SCOPE_IDENTITY());

        INSERT INTO Sales.MiniOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

        UPDATE Production.MiniProducts
        SET Quantity = Quantity - @Quantity
        WHERE ProductID = @ProductID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        EXEC dbo.usp_LogError;
        THROW;
    END CATCH
END;
GO

/* --------------------------------------------------------------------------
   Inline TVF — สรุปออเดอร์ต่อลูกค้า
   -------------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION Sales.ufn_GetCustomerOrderSummary (@CustID int)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        LineCount = COUNT(d.ProductID),
        MerchandiseTotal = SUM(d.UnitPrice * d.Quantity * (1 - d.Discount)),
        o.Freight
    FROM Sales.MiniOrders AS o
    LEFT JOIN Sales.MiniOrderDetails AS d
        ON d.OrderID = o.OrderID
    WHERE o.CustID = @CustID
    GROUP BY o.OrderID, o.OrderDate, o.Status, o.Freight
);
GO

/* --------------------------------------------------------------------------
   Soft-delete: INSTEAD OF DELETE บน MiniOrders
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_InsteadOfDelete
ON Sales.MiniOrders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET
        o.Status = 'Cancelled',
        o.LastModifiedUtc = SYSUTCDATETIME(),
        o.ModifiedBy = SUSER_SNAME()
    FROM Sales.MiniOrders AS o
    INNER JOIN deleted AS d
        ON d.OrderID = o.OrderID;
END;
GO

/* --------------------------------------------------------------------------
   Optional audit table + AFTER trigger
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Sales.MiniOrdersAudit', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.MiniOrdersAudit
    (
        AuditID       int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        AuditUtc      datetime2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
        AuditAction   char(1) NOT NULL, -- I / U
        OrderID       int NOT NULL,
        CustID        int NULL,
        Status        varchar(20) NULL,
        ModifiedBy    sysname NULL
    );
END;
GO

CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_Audit
ON Sales.MiniOrders
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sales.MiniOrdersAudit (AuditAction, OrderID, CustID, Status, ModifiedBy)
    SELECT
        CASE WHEN d.OrderID IS NULL THEN 'I' ELSE 'U' END,
        i.OrderID,
        i.CustID,
        i.Status,
        SUSER_SNAME()
    FROM inserted AS i
    LEFT JOIN deleted AS d
        ON d.OrderID = i.OrderID;
END;
GO

/* --------------------------------------------------------------------------
   Security demo — GRANT EXECUTE (รันในคลาสได้)
   -------------------------------------------------------------------------- */
/*
IF DATABASE_PRINCIPAL_ID(N'ApiCaller') IS NULL
    CREATE USER ApiCaller WITHOUT LOGIN;

DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniCustomers TO ApiCaller;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniOrders TO ApiCaller;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniOrderDetails TO ApiCaller;
DENY SELECT, UPDATE ON Production.MiniProducts TO ApiCaller;

GRANT EXECUTE ON Sales.usp_CreateCustomer TO ApiCaller;
GRANT EXECUTE ON Sales.usp_PlaceOrder TO ApiCaller;
GRANT SELECT ON Sales.ufn_GetCustomerOrderSummary TO ApiCaller;
GRANT EXECUTE ON dbo.usp_LogError TO ApiCaller; -- ถ้า proc เรียกข้าม schema แล้ว ownership chain ขาด

EXECUTE AS USER = N'ApiCaller';
DECLARE @c int, @o int;
EXEC Sales.usp_CreateCustomer
    @CompanyName = N'Api Co', @ContactName = N'Api', @ContactTitle = N'Dev',
    @Address = N'1 Api St', @City = N'Bangkok', @Country = N'Thailand',
    @Phone = N'02-999-0000', @CustID = @c OUTPUT;
EXEC Sales.usp_PlaceOrder
    @CustID = @c, @ProductID = 859, @Quantity = 1, @UnitPrice = 50, @OrderID = @o OUTPUT;
SELECT * FROM Sales.ufn_GetCustomerOrderSummary(@c);
-- SELECT * FROM Sales.MiniOrders; -- ควร DENY
REVERT;
*/

/* --------------------------------------------------------------------------
   Smoke test
   -------------------------------------------------------------------------- */
DECLARE @CustID int, @OrderID int;

EXEC Sales.usp_CreateCustomer
    @CompanyName = N'Solution Demo Co',
    @ContactName = N'Sam',
    @ContactTitle = N'Buyer',
    @Address = N'100 Demo Rd',
    @City = N'Bangkok',
    @Country = N'Thailand',
    @Phone = N'02-333-4444',
    @CustID = @CustID OUTPUT;

EXEC Sales.usp_PlaceOrder
    @CustID = @CustID,
    @ProductID = 860,
    @Quantity = 1,
    @UnitPrice = 199.00,
    @OrderID = @OrderID OUTPUT;

SELECT @CustID AS CustID, @OrderID AS OrderID;
SELECT * FROM Sales.ufn_GetCustomerOrderSummary(@CustID);

-- Soft-delete
DELETE FROM Sales.MiniOrders WHERE OrderID = @OrderID;
SELECT OrderID, Status, LastModifiedUtc, ModifiedBy
FROM Sales.MiniOrders WHERE OrderID = @OrderID;

SELECT TOP (5) * FROM Sales.MiniOrdersAudit ORDER BY AuditID DESC;
SELECT TOP (5) * FROM dbo.ErrorLog ORDER BY ErrorLogID DESC;
GO
