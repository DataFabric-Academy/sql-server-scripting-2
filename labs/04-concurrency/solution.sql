/*
================================================================================
  Lab 04 — solution.sql
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*------------------------------------------------------------------------------
  TODO 1
------------------------------------------------------------------------------*/
SELECT
    name,
    snapshot_isolation_state_desc,
    is_read_committed_snapshot_on
FROM sys.databases
WHERE name = DB_NAME();
GO

/*------------------------------------------------------------------------------
  TODO 2 — matrix
------------------------------------------------------------------------------*/
SELECT *
FROM (VALUES
    (N'READ UNCOMMITTED', N'Y', N'Y', N'Y'),
    (N'READ COMMITTED',   N'N', N'Y', N'Y'),
    (N'REPEATABLE READ',  N'N', N'N', N'Y'),
    (N'SERIALIZABLE',     N'N', N'N', N'N')
) AS M (IsolationLevel, AllowsDirtyRead, AllowsNonRepeatable, AllowsPhantom);
GO

/*------------------------------------------------------------------------------
  TODO 3 — ลำดับ Dirty Read (อ้างอิง sessions/01-*)
------------------------------------------------------------------------------
  Session B (writer):
    Step 2: BEGIN TRAN; UPDATE Person.PersonPhone … BusinessEntityID=105;
            (ยังไม่ COMMIT)
  Session A (reader):
    Step 3: SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
            SELECT … BusinessEntityID=105;  -- เห็นค่า dirty
  Session B:
    Step 4: ROLLBACK;
  Session A:
    Step 5: SELECT อีกครั้ง — กลับค่าเดิม

  สคริปต์จริงอยู่ที่ sessions/01-dirty-read-s1.sql และ s2.sql
*/

PRINT N'TODO3: ใช้คู่ไฟล์ sessions/01-dirty-read-s*.sql ตาม Step ในไฟล์';
GO

/*------------------------------------------------------------------------------
  TODO 4 — สต็อก
------------------------------------------------------------------------------*/
PRINT N'READ COMMITTED กันได้แค่ dirty read';
PRINT N'ระหว่างอ่าน Quantity กับ UPDATE ตัดสต็อก Session อื่นอาจตัดสต็อกไปแล้ว → oversell';
PRINT N'ทางเลือก: (1) BEGIN TRAN + UPDLOCK/HOLDLOCK ตอนอ่านสต็อก';
PRINT N'         (2) REPEATABLE READ / SERIALIZABLE สำหรับช่วงอ่าน-เขียน';
PRINT N'         (3) SNAPSHOT + ตรวจแถว version / retry เมื่อ conflict';
PRINT N'         (4) single protected UPDATE … WHERE Quantity >= @Need แล้วตรวจ @@ROWCOUNT';
GO

/*------------------------------------------------------------------------------
  TODO 5 — Lost update / Double read (สไลด์ 56)
------------------------------------------------------------------------------*/
PRINT N'5.1 Lost update: Session A อ่านค่า → Session B อ่าน+เขียน+commit → Session A เขียนทับด้วยค่าเก่า';
PRINT N'    กันด้วย: rowversion/optimistic check, UPDLOCK ตอนอ่าน, หรือ UPDATE แบบมีเงื่อนไขใน statement เดียว';
PRINT N'5.2 Double read: ระหว่าง index scan มีแถวที่ key เลื่อน ทำให้แถวเดิมถูกอ่านซ้ำ (ต่างจาก Phantom ที่เป็นแถวใหม่เข้าช่วง predicate)';
GO

/*------------------------------------------------------------------------------
  TODO 6 — สไลด์ 59: session isolation vs table hint
------------------------------------------------------------------------------*/
PRINT N'A) SET TRANSACTION ISOLATION LEVEL SERIALIZABLE มีผลทั้ง session จนเปลี่ยนกลับ';
PRINT N'B) WITH (SERIALIZABLE) มีผลเฉพาะ statement/ตารางที่ใส่ hint — เหมาะเมื่ออยากจำกัดขอบเขต';
PRINT N'โครง: SET XACT_ABORT ON; BEGIN TRY BEGIN TRAN … Mini* DML … COMMIT; CATCH: IF XACT_STATE()=-1 ROLLBACK;';
GO

PRINT N'===== Lab 04 solution ครบ =====';
GO
