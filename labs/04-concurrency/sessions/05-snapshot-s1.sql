/*
================================================================================
  05-snapshot-s1.sql  === SESSION 1 (Reader — SNAPSHOT) ===
  คู่กับ: 05-snapshot-s2.sql
================================================================================
  เป้าหมาย: อ่านแบบ row versioning — ไม่เห็น dirty และไม่ non-repeatable
  ใน transaction เดียวกันจะเห็นข้อมูล ณ ตอน BEGIN TRAN (statement ของ writer
  ที่ commit หลังนั้นไม่กระทบภาพที่ S1 เห็นจนกว่าจะจบ tran)
================================================================================
*/

USE AdventureWorks;
GO

/* Step 0 — เปิดอนุญาต SNAPSHOT ที่ระดับ database (ทำครั้งเดียวต่อ DB) */
-- ต้องไม่มี transaction รบกวนมาก; ถ้า error ให้ลองตอนเครื่องว่าง
IF EXISTS
(
    SELECT 1 FROM sys.databases
    WHERE name = DB_NAME()
      AND snapshot_isolation_state_desc <> N'ON'
)
BEGIN
    DECLARE @sql NVARCHAR(300) =
        N'ALTER DATABASE ' + QUOTENAME(DB_NAME()) + N' SET ALLOW_SNAPSHOT_ISOLATION ON;';
    EXEC sys.sp_executesql @sql;
    PRINT N'ALLOW_SNAPSHOT_ISOLATION turned ON';
END
ELSE
    PRINT N'ALLOW_SNAPSHOT_ISOLATION already ON';

SELECT name, snapshot_isolation_state_desc, is_read_committed_snapshot_on
FROM sys.databases
WHERE name = DB_NAME();
GO

/* Step 1 — เริ่ม SNAPSHOT transaction และอ่านค่า */
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;

SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* >>> Step 2 ใน SESSION 2: UPDATE + COMMIT <<< */

/* Step 3 — อ่านซ้ำ: ยังเห็นค่าเดิมตอนเริ่ม tran (ไม่ non-repeatable) */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;

COMMIT TRANSACTION;
GO

/* Step 4 — นอก transaction แล้ว จะเห็นค่าล่าสุดที่ S2 commit */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;

-- คืนค่า
UPDATE Person.PersonPhone
SET PhoneNumber = N'555-555-0113'
WHERE BusinessEntityID = 105;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

/*
  หมายเหตุ RCSI (พูดในคลาส):
  ALTER DATABASE … SET READ_COMMITTED_SNAPSHOT ON;
  ทำให้ isolation แบบ READ COMMITTED ใช้ row versions ระดับ statement
  ไม่ต้องเขียน SET TRANSACTION ISOLATION LEVEL SNAPSHOT ในทุก session
  แต่พฤติกรรมไม่เหมือน full SNAPSHOT transaction ทั้งก้อน
*/
