/*
================================================================================
  Lab 02 — exercise.sql  (ผู้เรียน)
  Error Handling
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*------------------------------------------------------------------------------
  TODO 1 — TRY/CATCH + ERROR_* 
  จงเขียนบล็อกที่พยายามแปลงสตริง 'ABC' เป็น INT (จะ error)
  ใน CATCH ให้ SELECT แสดง ERROR_NUMBER, ERROR_MESSAGE, ERROR_LINE
------------------------------------------------------------------------------*/
-- TODO 1: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 2 — THROW business error + บันทึก dbo.ErrorLog
  เงื่อนไข: ถ้า Quantity ของ ProductID 860 ใน MiniProducts < 1000
  ให้ THROW error_number 50100 ข้อความภาษาอังกฤษสั้น ๆ
  และใน CATCH ให้ INSERT ลง dbo.ErrorLog แล้ว THROW; (rethrow)
  ถ้า Quantity >= 1000 ให้ PRINT ว่าผ่านเงื่อนไข
------------------------------------------------------------------------------*/
-- TODO 2: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 3 — FORMATMESSAGE
  ใช้ FORMATMESSAGE สร้างข้อความ:
    'Order for Product %d needs %d units'
  โดยใส่ ProductID = 854 และ units = 30
  จากนั้น THROW 50110 ด้วยข้อความนั้นใน TRY/CATCH
  ใน CATCH ให้ PRINT ERROR_MESSAGE() อย่างเดียว (ไม่ต้อง rethrow ก็ได้)
------------------------------------------------------------------------------*/
-- TODO 3: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 4 — แยก informational กับ error
  เรียก RAISERROR severity 10 พร้อมข้อความใดก็ได้ใน TRY
  จากนั้นเรียก RAISERROR severity 16
  อธิบายใน PRINT ภายใน CATCH ว่าทำไมถึงเข้า CATCH แค่ครั้งหลัง
------------------------------------------------------------------------------*/
-- TODO 4: WRITE YOUR CODE HERE


GO

PRINT N'===== Lab 02 exercise: ส่งงานเมื่อครบ TODO =====';
GO
