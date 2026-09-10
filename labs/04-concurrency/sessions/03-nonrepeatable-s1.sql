/*
================================================================================
  03-nonrepeatable-s1.sql  === SESSION 1 (Reader) ===
  คู่กับ: 03-nonrepeatable-s2.sql
================================================================================
  ส่วน A: READ COMMITTED อนุญาต non-repeatable read
  ส่วน B: REPEATABLE READ ป้องกันได้ (writer จะถูก block)
================================================================================
*/

USE AdventureWorks;
GO

/*==============================================================================
  PART A — READ COMMITTED (เจอ non-repeatable)
==============================================================================*/

/* Step 1 */
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;

SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* >>> Step 2 ใน SESSION 2: UPDATE (autocommit) <<< */

/* Step 3 — อ่านซ้ำใน transaction เดิม */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
-- ค่าเปลี่ยนได้ = non-repeatable read

COMMIT TRANSACTION;
GO

/*==============================================================================
  PART B — REPEATABLE READ (กันได้)
==============================================================================*/

/* Step 4 */
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;

SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* >>> Step 5 ใน SESSION 2: UPDATE จะถูก block <<< */

/* Step 6 — อ่านซ้ำ (ยังเป็นค่าเดิม) */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;

COMMIT TRANSACTION;
-- หลัง COMMIT แล้ว SESSION 2 ที่ถูก block จะวิ่งต่อ
GO

/* Step 7 — ดูค่าหลังทุกอย่างจบ (อาจถูก S2 แก้แล้ว — คืนค่าด้านล่าง) */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;

-- คืนค่ามาตรฐานของ AdventureWorks (ปรับถ้าเครื่องคุณต่าง)
UPDATE Person.PersonPhone
SET PhoneNumber = N'555-555-0113'
WHERE BusinessEntityID = 105;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
