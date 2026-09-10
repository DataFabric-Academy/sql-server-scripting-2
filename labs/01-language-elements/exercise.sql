/*
================================================================================
  Lab 01 — exercise.sql  (ผู้เรียน)
  Language Elements & Scripting
================================================================================
  คำสั่ง:
    - ทำ TODO ทั้ง 4 ข้อใน AdventureWorks
    - อย่าดู solution.sql จนกว่าจะลองเองแล้ว
    - แต่ละข้อควรรันได้แยก batch (มี GO กั้นไว้แล้ว)
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*------------------------------------------------------------------------------
  TODO 1 — Variables & Expressions
  คำนวณยอดบรรทัดจาก MiniProducts:
    ProductID 854, สมมติขาย 12 ชิ้น ส่วนลด 15%
    UnitPrice ให้ดึงจาก Production.Product.ListPrice ของ ProductID เดียวกัน
  แสดง: ProductID, ProductName, ListPrice, Qty, DiscountPct, LineTotal
------------------------------------------------------------------------------*/
-- TODO 1: ประกาศตัวแปร + คำนวณ LineTotal แล้ว SELECT แสดงผล
-- WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 2 — IF / ELSE + predicate ที่ถูกต้อง
  นับจำนวน Person.Person ที่ MiddleName เป็น NULL
  ถ้า count > 0 ให้ PRINT ข้อความพร้อมจำนวน
  ถ้าเป็น 0 ให้ PRINT ว่าไม่พบ
  (ห้ามใช้ = NULL)
------------------------------------------------------------------------------*/
-- TODO 2: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 3 — WHILE + CONTINUE + BREAK
  วน ProductID จาก 854 ถึง 870
    - ถ้าไม่มีใน Production.MiniProducts ให้ CONTINUE
    - พิมพ์ ProductID และ Quantity
    - ถ้า Quantity < 20 ให้ BREAK หลังพิมพ์
------------------------------------------------------------------------------*/
-- TODO 3: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 4 — Table variable vs Temp table
  4.1 สร้าง table variable @Cats เก็บ ProductCategoryID, Name จาก
      Production.ProductCategory แล้ว SELECT นับจำนวนแถว
  4.2 สร้าง #Cats แบบเดียวกัน (ข้าม GO ได้) แล้ว SELECT นับจำนวนแถว
      จากนั้น DROP #Cats
  (เป้าหมาย: เห็นความต่างเรื่อง scope / การใช้ข้าม batch)
------------------------------------------------------------------------------*/
-- TODO 4.1: table variable
-- WRITE YOUR CODE HERE


GO

-- TODO 4.2: temp table (สร้าง / ใส่ข้อมูล / นับ / drop)
-- WRITE YOUR CODE HERE


GO

PRINT N'===== Lab 01 exercise: ส่งงานเมื่อครบ 4 TODO =====';
GO
