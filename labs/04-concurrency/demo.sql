/*
================================================================================
  Lab 04 — demo.sql  (Overview สำหรับ Instructor)
  Concurrency & Isolation Levels
================================================================================
  ไฟล์นี้เป็นภาพรวม + helper queries
  การ demo จริงให้ใช้คู่ไฟล์ใน sessions/ (เปิด 2 query windows)
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*==============================================================================
  SECTION A — ปัญหา concurrency (conceptual cheat-sheet)
==============================================================================
  Dirty Read          : อ่านข้อมูลที่ยังไม่ commit
  Non-Repeatable Read : อ่านแถวเดิมซ้ำได้ค่าใหม่หลังคนอื่น commit UPDATE/DELETE
  Phantom Read        : อ่านชุดตามเงื่อนไขซ้ำแล้วมีแถวใหม่โผล่ (INSERT)

  Isolation (pessimistic)     Dirty   NonRep   Phantom
  ------------------------------------------------------
  READ UNCOMMITTED              Y       Y        Y
  READ COMMITTED (default)      N       Y        Y
  REPEATABLE READ               N       N        Y
  SERIALIZABLE                  N       N        N

  SNAPSHOT (optimistic)         N       N        N
  (RCSI = READ_COMMITTED_SNAPSHOT ON ที่ระดับ DB → statement-level versioning)
*/

SELECT
    name,
    snapshot_isolation_state_desc,
    is_read_committed_snapshot_on
FROM sys.databases
WHERE name = DB_NAME();
GO

/*==============================================================================
  SECTION B — ค่าเริ่มต้นของข้อมูลที่ใช้ใน sessions
==============================================================================*/

-- PersonPhone ที่ใช้ใน dirty / read-committed / non-repeatable
SELECT BusinessEntityID, PhoneNumber, PhoneNumberTypeID
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
-- ค่าต้นทางใน AdventureWorks มักเป็น 555-555-0113 — จดไว้ก่อน demo

-- ProductCategory สำหรับ phantom
SELECT ProductCategoryID, Name
FROM Production.ProductCategory
ORDER BY ProductCategoryID;
GO

/*==============================================================================
  SECTION C — แผนการรัน sessions (อ่านให้ผู้เรียนก่อนเปิดหน้าต่างที่ 2)
==============================================================================

  01 Dirty Read
     S2: BEGIN TRAN + UPDATE PhoneNumber (ยังไม่ commit)
     S1: SET READ UNCOMMITTED → SELECT เห็นค่าใหม่ (dirty)
     S2: ROLLBACK
     S1: SELECT อีกครั้ง → กลับค่าเดิม

  02 Read Committed
     S2: BEGIN TRAN + UPDATE (ยังไม่ commit)
     S1: SET READ COMMITTED → SELECT จะถูก block จน S2 ROLLBACK/COMMIT

  03 Non-Repeatable
     S1: READ COMMITTED + BEGIN TRAN + SELECT
     S2: UPDATE + (auto commit)
     S1: SELECT ซ้ำใน tran เดียวกัน → ค่าเปลี่ยน
     จากนั้นลอง REPEATABLE READ → S2 จะถูก block จน S1 COMMIT

  04 Phantom
     S1: REPEATABLE READ + COUNT(*) ProductCategory
     S2: INSERT category ใหม่
     S1: COUNT ซ้ำ → ตัวเลขเพิ่ม (phantom)
     ลอง SERIALIZABLE → S2 INSERT ถูก block

  05 Snapshot
     เปิด ALLOW_SNAPSHOT_ISOLATION
     S1: SNAPSHOT + BEGIN TRAN + SELECT
     S2: UPDATE + COMMIT
     S1: SELECT ซ้ำ → ยังเห็นเวอร์ชันเดิมตอนเริ่ม tran
*/

PRINT N'เปิด sessions/01-dirty-read-s1.sql และ s2.sql ในคนละหน้าต่างเพื่อเริ่ม demo';
GO

/*==============================================================================
  SECTION D — Cleanup helpers (รันเมื่อ demo ค้าง)
==============================================================================*/

-- คืนเบอร์โทร (แก้ค่าให้ตรงของเดิมในเครื่องคุณถ้าต่าง)
/*
UPDATE Person.PersonPhone
SET PhoneNumber = N'555-555-0113'
WHERE BusinessEntityID = 105;
*/

-- ลบ category ที่ insert ระหว่าง phantom demo
/*
DELETE FROM Production.ProductCategory
WHERE Name IN (N'Safety Gear', N'Gifts, Goodies and More', N'Lab Phantom Category');
*/

PRINT N'===== Lab 04 overview พร้อมแล้ว — ไปที่โฟลเดอร์ sessions/ =====';
GO
