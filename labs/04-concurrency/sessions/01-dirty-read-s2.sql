/*
================================================================================
  01-dirty-read-s2.sql  === SESSION 2 (Writer) ===
  คู่กับ: 01-dirty-read-s1.sql
================================================================================
*/

USE AdventureWorks;
GO

/* >>> รอให้ SESSION 1 ทำ Step 1 เสร็จก่อน <<< */

/* Step 2 — แก้ค่าแล้วค้าง transaction ไว้ */
BEGIN TRANSACTION;

UPDATE Person.PersonPhone
SET PhoneNumber = N'999-555-9999'
WHERE BusinessEntityID = 105;

SELECT BusinessEntityID, PhoneNumber, N'uncommitted in S2' AS Note
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
GO

/* >>> ไปรัน Step 3 ใน SESSION 1 <<< */

/* Step 4 — ยกเลิกการแก้ไข */
ROLLBACK TRANSACTION;
GO

/* >>> ไปรัน Step 5 ใน SESSION 1 <<< */
