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
  SECTION A — ปัญหา concurrency ตามสไลด์ 56
==============================================================================
  Dirty Read          : อ่านข้อมูลที่ยังไม่ commit
  Lost Update         : สองฝ่าย UPDATE แล้วผลของฝ่ายหนึ่งหาย
  Non-Repeatable Read : อ่านแถวเดิมซ้ำได้ค่าใหม่หลังคนอื่น commit UPDATE/DELETE
  Phantom Read        : อ่านชุดตามเงื่อนไขซ้ำแล้วมีแถวใหม่โผล่ (INSERT) / หายไป
  Double Read         : อ่านช่วงเดียวกันซ้ำเพราะ index key เลื่อนระหว่าง scan

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
  SECTION A2 — SQL Server 2025: Optimized Locking (ตรวจก่อน demo blocking)
  เอกสาร: https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking
==============================================================================*/
SELECT
    name,
    compatibility_level,
    is_accelerated_database_recovery_on,
    is_read_committed_snapshot_on,
    is_optimized_locking_on,
    DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') AS IsOptimizedLockingOn
FROM sys.databases
WHERE name = DB_NAME();

PRINT N'ถ้า is_optimized_locking_on = 1 บน SQL Server 2025 — blocking/lock memory อาจต่างจาก demo คลาสสิก';
PRINT N'Optimized locking ต้องการ ADR; LAQ ได้ประโยชน์เต็มเมื่อมี RCSI';
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
  SECTION E — แพทเทิร์นสไลด์ 59 (Isolation ระดับ session vs hint)
  อธิบายโครง — ไม่รัน INSERT จริงใน overview (กันข้อมูลซ้ำ)
  ดูรายละเอียดโค้ดเต็มบนสไลด์ / ทำใน exercise TODO 6
==============================================================================
  แนวทาง A:
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET XACT_ABORT ON;
    BEGIN TRY BEGIN TRAN
        -- MiniCustomers / MiniOrders / MiniOrderDetails / UPDATE MiniProducts
    COMMIT; END TRY BEGIN CATCH
        IF (XACT_STATE()) = -1 ROLLBACK TRANSACTION;
    END CATCH
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  แนวทาง B:
    ไม่ SET isolation ทั้ง session
    ใส่ WITH (SERIALIZABLE) บน INSERT MiniOrderDetails และ UPDATE MiniProducts
*/

PRINT N'===== Lab 04 overview พร้อมแล้ว — ไปที่โฟลเดอร์ sessions/ =====';
GO
