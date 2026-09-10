CREATE PROCEDURE [Sales].[usp_CreateCustomer]
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
        IF NULLIF(LTRIM(RTRIM(@CompanyName)), N'') IS NULL
            OR NULLIF(LTRIM(RTRIM(@ContactName)), N'') IS NULL
            OR NULLIF(LTRIM(RTRIM(@Phone)), N'') IS NULL
        BEGIN
            THROW 52001, N'CompanyName, ContactName และ Phone ต้องไม่ว่าง', 1;
        END;

        INSERT INTO [Sales].[MiniCustomers]
        (
            [CompanyName], [ContactName], [ContactTitle], [Address],
            [City], [Region], [PostalCode], [Country], [Phone]
        )
        VALUES
        (
            @CompanyName, @ContactName, @ContactTitle, @Address,
            @City, @Region, @PostalCode, @Country, @Phone
        );

        SET @CustID = CONVERT(int, SCOPE_IDENTITY());
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        EXEC [dbo].[usp_LogError];
        THROW;
    END CATCH
END;
GO
