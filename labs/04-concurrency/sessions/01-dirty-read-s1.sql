/*
================================================================================
  01-dirty-read-s1.sql  === SESSION 1 (Reader) ===
  คู่กับ: 01-dirty-read-s2.sql
================================================================================
  เป้าหมาย: แสดง Dirty Read ด้วย READ UNCOMMITTED
================================================================================
*/

USE AdventureWorks;
GO

/* Step 1 — จดค่าเดิม */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
-- คาดหวังประมาณ: 555-555-0113
GO

/* >>> ไปรัน Step 2 ใน SESSION 2 <<< */

/* Step 3 — อ่านแบบ dirty */
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
-- สังเกต: เห็นค่าที่ SESSION 2 แก้แล้วแต่ยังไม่ commit (เช่น 999-555-9999)
GO

/* >>> ไปรัน Step 4 ใน SESSION 2 (ROLLBACK) <<< */

/* Step 5 — อ่านอีกครั้งหลัง rollback */
SELECT BusinessEntityID, PhoneNumber
FROM Person.PersonPhone
WHERE BusinessEntityID = 105;
-- กลับเป็นค่าเดิม
GO

-- คืน isolation ปกติของ session
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
