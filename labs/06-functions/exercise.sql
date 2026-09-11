/*
==============================================================================
 Lab 06 — Functions | Student Exercises (TODO only)
 Database: AdventureWorks / AdventureWorks2022
==============================================================================
*/
USE AdventureWorks;
GO

/* ==========================================================================
   Exercise 1 — Scalar UDF
   ==========================================================================
   TODO: สร้าง Production.ufn_MiniProductQty(@ProductID)
   - RETURNS int
   - คืน Quantity จาก Production.MiniProducts (ไม่พบให้คืน NULL)
*/
-- TODO
GO

-- TODO: ทดสอบ SELECT Production.ufn_MiniProductQty(854);
GO

/* ==========================================================================
   Exercise 2 — Inline TVF (แนะนำ)
   ==========================================================================
   TODO: สร้าง Sales.ufn_MiniCustomerOrders(@CustID)
   - RETURNS TABLE แบบ inline
   - คืน OrderID, OrderDate, Status, Freight ของลูกค้า
   - ทดสอบด้วย CROSS APPLY จาก Sales.MiniCustomers
*/
-- TODO
GO

/* ==========================================================================
   Exercise 3 — Multi-statement TVF + เปรียบเทียบ
   ==========================================================================
   TODO A: สร้าง Sales.ufn_OpenOrders_mstvf()
           คืนเฉพาะ MiniOrders ที่ Status = 'Open'
           (OrderID, CustID, OrderDate, Freight)

   TODO B: สร้าง Sales.ufn_OpenOrders_inline() ทำหน้าที่เดียวกันแบบ inline

   TODO C: เขียนคอมเมนต์สั้น ๆ ว่าควรใช้ตัวไหนเป็นค่าเริ่มต้น และทำไม
           (ไม่ต้องรัน STATISTICS ก็ได้ แต่แนะนำให้ลอง)
*/
-- TODO
GO

/* ==========================================================================
   Exercise 4 — Alternative โดยไม่ใช้ Scalar ใน SELECT list
   ==========================================================================
   TODO: เขียนคำสั่งที่แสดง SalesOrderID, Freight และ Bucket (LOW/MID/HIGH)
         จาก Sales.SalesOrderHeader TOP 100
         โดยใช้ CASE หรือ CROSS APPLY — ห้ามเรียก Scalar UDF
*/
-- TODO
GO

/* ==========================================================================
   Exercise 5 — Deterministic vs Nondeterministic (สไลด์ 80)
   ==========================================================================
   TODO: PRINT อธิบายสั้น ๆ พร้อมยกตัวอย่าง
         - Deterministic: เช่น ABS(@x), หรือ UDF ที่คำนวณจากพารามิเตอร์อย่างเดียว
         - Nondeterministic: เช่น GETDATE(), NEWID(), หรือ UDF ที่อ่านตารางที่เปลี่ยนได้
         และบอกว่าทำไม indexed view / persisted computed มักต้องการ deterministic
*/
-- TODO
GO
