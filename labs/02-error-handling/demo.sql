/*
================================================================================
  Lab 02 — demo.sql  (Instructor Demo)
  Error Handling
================================================================================
  DB: AdventureWorks
  หมายเหตุ: ส่วน sp_addmessage ทำงานบน master — ต้องมีสิทธิ์เหมาะสม
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*==============================================================================
  SECTION A — RAISERROR พื้นฐาน
==============================================================================
  severity:
    0–10  = info (ไม่เข้า CATCH)
   11–16  = user/correctable (เข้า CATCH ได้)
   17–19  = software/resource
   20–25  = fatal (มักตัด connection)
*/

RAISERROR(N'นี่คือ informational message (severity 10)', 10, 1);
GO

-- severity 16 → ถือเป็น error
BEGIN TRY
    RAISERROR(N'RAISERROR severity 16 — จะถูกจับใน CATCH', 16, 1);
    PRINT N'บรรทัดนี้จะไม่ถูกรัน';
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()    AS ErrorNumber,
        ERROR_SEVERITY()  AS ErrorSeverity,
        ERROR_STATE()     AS ErrorState,
        ERROR_LINE()      AS ErrorLine,
        ERROR_MESSAGE()   AS ErrorMessage;
END CATCH
GO

-- substitution parameters แบบ printf-style
RAISERROR(N'ProductID %d มีสต็อกเหลือ %d', 10, 1, 854, 42);
GO

/*==============================================================================
  SECTION B — Custom message: sp_addmessage + sys.messages
==============================================================================*/

USE master;
GO

-- ลบของเก่าถ้ามี (idempotent demo)
IF EXISTS (SELECT 1 FROM sys.messages WHERE message_id = 55055)
    EXEC sp_dropmessage @msgnum = 55055, @lang = 'all';
GO

EXEC sp_addmessage
    @msgnum     = 55055,
    @severity  = 16,
    @msgtext    = N'Lab custom error: Product %d stock issue — detail: %s',
    @lang       = 'us_english',
    @with_log   = 'false',
    @replace    = 'replace';
GO

USE AdventureWorks;
GO

SELECT message_id, language_id, severity, text
FROM sys.messages
WHERE message_id = 55055;
GO

BEGIN TRY
    RAISERROR(55055, 16, 1, 854, N'Quantity would become negative');
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH
GO

/*==============================================================================
  SECTION C — FORMATMESSAGE
==============================================================================
  สร้างข้อความโดยยังไม่ raise — เหมาะกับ log / ประกอบ message ก่อน THROW
*/

DECLARE @msg NVARCHAR(2048) =
    FORMATMESSAGE(55055, 859, N'Requested 9999 units');

SELECT @msg AS FormattedOnly;

BEGIN TRY
    THROW 50001, @msg, 1;  -- ใช้ข้อความที่ format แล้ว
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH
GO

/*==============================================================================
  SECTION D — THROW vs RAISERROR
==============================================================================*/

PRINT N'--- THROW ad-hoc (error_number >= 50000) ---';
BEGIN TRY
    THROW 50010, N'THROW ad-hoc: validation failed', 1;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg, ERROR_STATE() AS ErrState;
END CATCH
GO

PRINT N'--- ความต่างสำคัญ: statement ก่อน THROW ต้องมี semicolon ---';
BEGIN TRY
    DECLARE @x INT = 1;
    THROW 50011, N'OK เพราะมี ; หลัง DECLARE/SET โดยนัยของ batch structure', 1;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH
GO

/*==============================================================================
  SECTION E — TRY/CATCH + ERROR_* functions + เขียน ErrorLog
==============================================================================*/

BEGIN TRY
    DECLARE @a DECIMAL(8,2) = 10;
    DECLARE @b DECIMAL(8,2) = 0;
    DECLARE @result DECIMAL(8,2);

    SET @result = @a / @b;  -- error 8134 Divide by zero
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

    PRINT N'บันทึก ErrorLog แล้ว — กำลัง rethrow';
    THROW;  -- rethrow ของ error เดิม (แนะนำ)
END CATCH
GO

SELECT TOP (3) *
FROM dbo.ErrorLog
ORDER BY ErrorLogID DESC;
GO

/*==============================================================================
  SECTION F — Errors ที่ CATCH ไม่ได้ / ไม่เข้าตามที่คาด
==============================================================================
  1) Syntax error ทั้ง batch → compile ล้ม ก่อนรัน TRY
  2) Severity สูงมากที่ตัด connection
  3) บาง DDL / การใช้ GO แยก batch ทำให้คนเข้าใจผิดว่า "ไม่ถูกจับ"

  Demo แบบปลอดภัย: แสดงว่า RAISERROR severity 10 ไม่เข้า CATCH
*/

BEGIN TRY
    RAISERROR(N'severity 10 จะไม่กระโดดเข้า CATCH', 10, 1);
    PRINT N'ยังอยู่ใน TRY ปกติ (severity 10 ไม่ abort)';
END TRY
BEGIN CATCH
    PRINT N'จะไม่เห็นข้อความนี้สำหรับ severity 10';
END CATCH
GO

-- Object ไม่มี: runtime error → จับได้
BEGIN TRY
    SELECT * FROM dbo.TableThatDoesNotExist_Lab02;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH
GO

/*==============================================================================
  SECTION G — Rethrow pattern สรุป (template ที่ใช้ต่อ Lab 03)
==============================================================================*/

BEGIN TRY
    -- business rule ตัวอย่าง
    IF NOT EXISTS
    (
        SELECT 1 FROM Production.MiniProducts WHERE ProductID = 854 AND Quantity > 0
    )
    BEGIN
        DECLARE @biz NVARCHAR(200) =
            FORMATMESSAGE(N'Product 854 is out of stock (lab demo)');
        THROW 50020, @biz, 1;
    END

    PRINT N'Stock OK — continue work…';
END TRY
BEGIN CATCH
    -- log ก่อนเสมอ
    INSERT INTO dbo.ErrorLog
    (
        UserName, ErrorNumber, ErrorSeverity, ErrorState,
        ErrorProcedure, ErrorLine, ErrorMessage
    )
    VALUES
    (
        SUSER_SNAME(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
        ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE()
    );

    THROW;
END CATCH
GO

/* cleanup custom message (optional) */
/*
USE master;
EXEC sp_dropmessage @msgnum = 55055, @lang = 'all';
USE AdventureWorks;
*/

/*==============================================================================
  SECTION — Managed Code / SQL CLR (สไลด์ 45) — conceptual only
==============================================================================
  ถ้าไม่ดัก exception ใน managed code เอง Message ID มักเป็น 6522
  ในคลาสนี้ไม่เขียน CLR — แค่รู้ว่าต้อง handle ที่ฝั่ง .NET
*/

PRINT N'Note (สไลด์ 45): SQL CLR / Managed Code errors มักรายงานเป็น 6522 ถ้าไม่ดักใน managed code';
PRINT N'SQL Server 2025: งาน regex หลายเคสใช้ REGEXP_* พื้นเมืองแทน CLR ได้ (compat 170) — ดู Lab 01 SECTION H';
GO

PRINT N'===== Lab 02 demo เสร็จสิ้น =====';
GO
