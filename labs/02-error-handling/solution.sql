/*
================================================================================
  Lab 02 — solution.sql
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*------------------------------------------------------------------------------
  TODO 1 — TRY/CATCH + ERROR_*
------------------------------------------------------------------------------*/
BEGIN TRY
    DECLARE @n INT = CAST(N'ABC' AS INT);
    SELECT @n AS ShouldNotSee;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()  AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE()    AS ErrorLine;
END CATCH
GO

/*------------------------------------------------------------------------------
  TODO 2 — THROW + ErrorLog + rethrow
------------------------------------------------------------------------------*/
BEGIN TRY
    DECLARE @Qty INT =
    (
        SELECT Quantity
        FROM Production.MiniProducts
        WHERE ProductID = 860
    );

    IF @Qty < 1000
    BEGIN
        THROW 50100, N'Product 860 quantity is below 1000 (lab rule)', 1;
    END

    PRINT N'ผ่านเงื่อนไข: Quantity >= 1000';
END TRY
BEGIN CATCH
    INSERT INTO dbo.ErrorLog
    (
        UserName, ErrorNumber, ErrorSeverity, ErrorState,
        ErrorProcedure, ErrorLine, ErrorMessage
    )
    VALUES
    (
        SUSER_SNAME(),
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE()
    );

    THROW;
END CATCH
GO

/*------------------------------------------------------------------------------
  TODO 3 — FORMATMESSAGE
------------------------------------------------------------------------------*/
BEGIN TRY
    DECLARE @msg NVARCHAR(200) =
        FORMATMESSAGE(N'Order for Product %d needs %d units', 854, 30);

    THROW 50110, @msg, 1;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH
GO

/*------------------------------------------------------------------------------
  TODO 4 — severity 10 vs 16
------------------------------------------------------------------------------*/
BEGIN TRY
    RAISERROR(N'Info only — severity 10', 10, 1);
    PRINT N'ยังอยู่ใน TRY หลัง severity 10';

    RAISERROR(N'Real error — severity 16', 16, 1);
    PRINT N'บรรทัดนี้ไม่ควรถึง';
END TRY
BEGIN CATCH
    PRINT N'เข้า CATCH เพราะ severity 16 (11+) เท่านั้นที่ถูกมองเป็น error ที่ abort statement และเข้า CATCH ได้ตามปกติ';
    PRINT ERROR_MESSAGE();
END CATCH
GO

PRINT N'===== Lab 02 solution ครบ =====';
GO
