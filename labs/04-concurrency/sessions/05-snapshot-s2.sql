/*
================================================================================
  05-snapshot-s2.sql  === SESSION 2 (Writer) ===
  คู่กับ: 05-snapshot-s1.sql
================================================================================
*/

USE AdventureWorks;
GO

/* >>> รอ SESSION 1 ทำ Step 0–1 เสร็จ (อยู่กลาง SNAPSHOT tran) <<< */

/* Step 2 — แก้แล้ว commit ทันที */
UPDATE Person.PersonPhone
SET PhoneNumber = N'777-555-7777'
WHERE BusinessEntityID = 105;

PRINT N'S2: committed 777-555-7777 — กลับไป S1 Step 3 (ควรยังเห็นค่าเดิมใน SNAPSHOT tran)';
GO

/* S1 จะคืนค่า 555-555-0113 ตอนท้าย */
