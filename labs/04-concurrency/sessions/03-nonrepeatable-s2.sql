/*
================================================================================
  03-nonrepeatable-s2.sql  === SESSION 2 (Writer) ===
  คู่กับ: 03-nonrepeatable-s1.sql
================================================================================
*/

USE AdventureWorks;
GO

/* >>> รอ SESSION 1 Part A Step 1 <<< */

/* Step 2 — UPDATE แล้ว commit ทันที (autocommit) */
UPDATE Person.PersonPhone
SET PhoneNumber = N'333-555-3333'
WHERE BusinessEntityID = 105;

PRINT N'S2 Step2: committed 333-555-3333 — กลับไป S1 Step 3';
GO

/* >>> รอ SESSION 1 Part B Step 4 <<< */

/* Step 5 — จะถูก block จน S1 COMMIT (REPEATABLE READ ถือ shared lock) */
UPDATE Person.PersonPhone
SET PhoneNumber = N'444-555-4444'
WHERE BusinessEntityID = 105;

PRINT N'S2 Step5: update ผ่านแล้วหลัง S1 commit';
GO

/* S1 จะคืนค่า 555-555-0113 ให้ตอนท้าย */
