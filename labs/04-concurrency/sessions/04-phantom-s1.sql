/*
================================================================================
  04-phantom-s1.sql  === SESSION 1 (Reader) ===
  คู่กับ: 04-phantom-s2.sql
================================================================================
  ส่วน A: REPEATABLE READ ยังเจอ phantom (INSERT แถวใหม่)
  ส่วน B: SERIALIZABLE กัน phantom ได้ (INSERT ถูก block)
================================================================================
*/

USE AdventureWorks;
GO

/*==============================================================================
  PART A — REPEATABLE READ (เจอ phantom)
==============================================================================*/

/* Step 1 */
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;

SELECT COUNT(*) AS CatCount
FROM Production.ProductCategory;
GO

/* >>> Step 2 ใน SESSION 2: INSERT category <<< */

/* Step 3 */
SELECT COUNT(*) AS CatCount
FROM Production.ProductCategory;
-- จำนวนเพิ่มได้ = phantom read

COMMIT TRANSACTION;
GO

/*==============================================================================
  PART B — SERIALIZABLE (กัน phantom)
==============================================================================*/

/* Step 4 */
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

SELECT COUNT(*) AS CatCount
FROM Production.ProductCategory;
GO

/* >>> Step 5 ใน SESSION 2: INSERT จะถูก block <<< */

/* Step 6 */
SELECT COUNT(*) AS CatCount
FROM Production.ProductCategory;
-- ต้องได้จำนวนเท่า Step 4

COMMIT TRANSACTION;
GO

/* Step 7 — สรุปหลังจบ + cleanup แถวที่ S2 insert */
SELECT ProductCategoryID, Name
FROM Production.ProductCategory
WHERE Name IN (N'Safety Gear', N'Gifts, Goodies and More');

DELETE FROM Production.ProductCategory
WHERE Name IN (N'Safety Gear', N'Gifts, Goodies and More');

SELECT COUNT(*) AS CatCountAfterCleanup
FROM Production.ProductCategory;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
