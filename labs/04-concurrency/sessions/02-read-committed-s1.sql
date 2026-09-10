/*
================================================================================
  02-read-committed-s1.sql  === SESSION 1 (Reader) ===
  คู่กับ: 02-read-committed-s2.sql
================================================================================
  เป้าหมาย: READ COMMITTED กัน dirty read → ถูก block จน writer จบ tran
================================================================================
*/

USE AdventureWorks;
GO

/* Step 1 — ค่าเดิม */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* >>> ไปรัน Step 2 ใน SESSION 2 <<< */

/* Step 3 — อ่านด้วย default / READ COMMITTED */
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

-- คำสั่งนี้จะรอ (blocking) จนกว่า SESSION 2 จะ ROLLBACK หรือ COMMIT
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* หลัง SESSION 2 rollback แล้ว query ด้านบนจะคืนค่าเดิม */

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
