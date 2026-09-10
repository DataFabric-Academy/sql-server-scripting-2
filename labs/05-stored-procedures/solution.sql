/*
==============================================================================
 Lab 05 — Stored Procedures | Solutions
 Database: AdventureWorks / AdventureWorks2022
==============================================================================
*/
USE AdventureWorks;
GO

/* ==========================================================================
   Exercise 1 — usp_LogError
   ========================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_LogError
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ErrorLog
    (
        UserName,
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage,
        XactState
    )
    VALUES
    (
        SUSER_SNAME(),
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        XACT_STATE()
    );
END;
GO

/* ==========================================================================
   Exercise 2 — Input / OUTPUT / RETURN
   ========================================================================== */
CREATE OR ALTER PROCEDURE Sales.usp_GetMiniProductStock
    @ProductID   int,
    @ProductName nvarchar(100) OUTPUT,
    @Quantity    int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @ProductName = p.ProductName,
        @Quantity = p.Quantity
    FROM Production.MiniProducts AS p
    WHERE p.ProductID = @ProductID;

    IF @ProductName IS NULL
        RETURN 1;

    RETURN 0;
END;
GO

DECLARE
    @name nvarchar(100),
    @qty  int,
    @rc   int;

EXEC @rc = Sales.usp_GetMiniProductStock
    @ProductID = 854,
    @ProductName = @name OUTPUT,
    @Quantity = @qty OUTPUT;

SELECT @rc AS ReturnCode, @name AS ProductName, @qty AS Quantity;
GO

/* ==========================================================================
   Exercise 3 — Error handling
   ========================================================================== */
CREATE OR ALTER PROCEDURE Sales.usp_SetMiniProductQty
    @ProductID int,
    @NewQty    int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @NewQty < 0
            THROW 50020, N'NewQty must be >= 0.', 1;

        UPDATE Production.MiniProducts
        SET Quantity = @NewQty
        WHERE ProductID = @ProductID;

        IF @@ROWCOUNT = 0
            THROW 50021, N'ProductID not found.', 1;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        EXEC dbo.usp_LogError;

        DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
        THROW;  -- rethrow original (หรือใช้ THROW ใหม่ตาม contract)
    END CATCH
END;
GO

-- สำเร็จ
EXEC Sales.usp_SetMiniProductQty @ProductID = 860, @NewQty = 30;

-- ล้มเหลว → ErrorLog
BEGIN TRY
    EXEC Sales.usp_SetMiniProductQty @ProductID = 860, @NewQty = -5;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

SELECT TOP (3) * FROM dbo.ErrorLog ORDER BY ErrorLogID DESC;
GO

/* ==========================================================================
   Exercise 4 — Nested + sniffing mitigation
   ========================================================================== */
CREATE OR ALTER PROCEDURE Sales.usp_GetActiveCustomerName
    @CustID int,
    @Name   nvarchar(40) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Name = c.CompanyName
    FROM Sales.MiniCustomers AS c
    WHERE c.CustID = @CustID
      AND c.IsActive = 1;

    IF @Name IS NULL
        THROW 50030, N'Active customer not found.', 1;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_GreetCustomer
    @CustID int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @name nvarchar(40);

    EXEC Sales.usp_GetActiveCustomerName
        @CustID = @CustID,
        @Name = @name OUTPUT;

    SELECT N'Hello, ' + @name AS Greeting, @@NESTLEVEL AS NestLevel;
END;
GO

EXEC Sales.usp_GreetCustomer @CustID = 1;
GO

/*
  Mitigation: OPTION (RECOMPILE)
  เหมาะเมื่อค่า parameter ทำให้ cardinality ต่างกันมาก และต้องการ plan ที่ถูกต้องทุกครั้ง
  แลกด้วย compile CPU เพิ่ม — ใช้กับ proc ที่เรียกไม่ถี่มากหรือ critical path ที่ผิด plan แพง
*/
CREATE OR ALTER PROCEDURE Sales.usp_CountOrdersByProduct
    @ProductID int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS OrderLineCount
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.ProductID = @ProductID
    OPTION (RECOMPILE);
END;
GO

EXEC Sales.usp_CountOrdersByProduct @ProductID = 870;
EXEC Sales.usp_CountOrdersByProduct @ProductID = 897;
GO
