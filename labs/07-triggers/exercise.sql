/*
==============================================================================
 Lab 07 — DML Triggers | Student Exercises (TODO only)
 Database: AdventureWorks / AdventureWorks2022
 Prerequisite: setup/01-create-lab-objects.sql
==============================================================================
*/
USE AdventureWorks;
GO

/* ==========================================================================
   Exercise 1 — AFTER INSERT audit บน MiniCustomers
   ==========================================================================
   TODO:
   - สร้างตาราง Sales.MiniCustomersAudit (AuditID, CustID, ActionUtc, Actor, CompanyName)
   - สร้าง AFTER INSERT trigger บน Sales.MiniCustomers
     บันทึก CustID + CompanyName จาก inserted
   - ทดสอบ INSERT ลูกค้าใหม่ 1 ราย
*/
-- TODO
GO

/* ==========================================================================
   Exercise 2 — AFTER UPDATE + UPDATE()
   ==========================================================================
   TODO:
   - สร้าง trigger บน Production.MiniProducts
   - ถ้า UPDATE(Quantity) และค่าใหม่ < ค่าเดิม ให้ INSERT ลง dbo.ErrorLog
     (จำลองคำเตือน: ใส่ ErrorNumber = 50040, ErrorMessage อธิบาย ProductID + qty เก่า/ใหม่)
   - ใช้ SET NOCOUNT ON และเขียนแบบ set-based
*/
-- TODO
GO

/* ==========================================================================
   Exercise 3 — INSTEAD OF DELETE soft-delete บน MiniCustomers
   ==========================================================================
   TODO:
   - สร้าง INSTEAD OF DELETE ที่เซ็ต IsActive = 0 แทนการลบจริง
   - ทดสอบ DELETE แล้ว SELECT ยืนยันว่าแถวยังอยู่และ IsActive = 0
*/
-- TODO
GO

/* ==========================================================================
   Exercise 4 — คำถามสั้น (ตอบในคอมเมนต์)
   ==========================================================================
   TODO: เขียนคำตอบสั้น ๆ ในคอมเมนต์ SQL
   1) AFTER กับ INSTEAD OF ต่างกันอย่างไร
   2) Nested vs Recursive trigger ต่างกันอย่างไร
   3) ยกตัวอย่าง 2 กรณีที่ไม่ควรใช้ trigger
*/
-- TODO: comments
GO
