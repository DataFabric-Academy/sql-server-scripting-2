/*
================================================================================
  02-read-committed-s2.sql  === SESSION 2 (Writer) ===
  คู่กับ: 02-read-committed-s1.sql
================================================================================
*/

USE AdventureWorks;
GO

/* >>> รอ SESSION 1 Step 1 <<< */

/* Step 2 — UPDATE ค้างไว้ */
BEGIN TRANSACTION;

UPDATE Person.PersonPhone
SET PhoneNumber = N'999-555-9999'
WHERE BusinessEntityID = 105;

PRINT N'S2: ถือ exclusive lock อยู่ — ไปรัน Step 3 ที่ S1 (จะถูก block)';
GO

/* >>> ไปรัน Step 3 ใน SESSION 1 แล้วสังเกตว่าค้าง <<< */

/* Step 4 — ปลด lock */
ROLLBACK TRANSACTION;
PRINT N'S2: ROLLBACK แล้ว — S1 ควรได้ผลลัพธ์ทันที';
GO
