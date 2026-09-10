/*
================================================================================
  04-phantom-s2.sql  === SESSION 2 (Writer / Inserter) ===
  คู่กับ: 04-phantom-s1.sql
================================================================================
*/

USE AdventureWorks;
GO

/* >>> รอ SESSION 1 Part A Step 1 <<< */

/* Step 2 — INSERT ภายใต้ REPEATABLE READ ของ S1 (ผ่านได้ → สร้าง phantom) */
INSERT INTO Production.ProductCategory ([Name])
VALUES (N'Safety Gear');

PRINT N'S2 Step2: inserted Safety Gear — กลับไป S1 Step 3';
GO

/* >>> รอ SESSION 1 Part B Step 4 <<< */

/* Step 5 — จะถูก block จน S1 COMMIT (SERIALIZABLE range lock) */
INSERT INTO Production.ProductCategory ([Name])
VALUES (N'Gifts, Goodies and More');

PRINT N'S2 Step5: insert ผ่านหลัง S1 commit — S1 จะ cleanup ให้';
GO
