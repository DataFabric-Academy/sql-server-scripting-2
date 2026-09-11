/*
==============================================================================
 Lab 05 — Stored Procedures | Student Exercises (TODO only)
 Database: AdventureWorks / AdventureWorks2022
 Prerequisite: setup/01-create-lab-objects.sql
 Hint: ดู demo.sql ถ้าติด — อย่าเปิด solution.sql จนกว่าจะลองเองแล้ว
==============================================================================
*/
USE AdventureWorks;
GO

/* ==========================================================================
   Exercise 1 — สร้าง usp_LogError (ถ้ายังไม่มีจาก demo)
   ==========================================================================
   TODO:
   - สร้าง dbo.usp_LogError ที่ INSERT ลง dbo.ErrorLog โดยใช้ ERROR_*()
     และเก็บ XACT_STATE() ในคอลัมน์ XactState
   - ใส่ SET NOCOUNT ON
*/
-- TODO: CREATE OR ALTER PROCEDURE dbo.usp_LogError ...
GO

/* ==========================================================================
   Exercise 2 — Input / OUTPUT / RETURN
   ==========================================================================
   TODO: สร้าง Sales.usp_GetMiniProductStock
   Parameters:
     @ProductID   int
     @ProductName nvarchar(100) OUTPUT
     @Quantity    int OUTPUT
   Behavior:
     - ถ้าไม่พบสินค้า RETURN 1
     - ถ้าพบ ให้เซ็ต OUTPUT แล้ว RETURN 0
     - ห้าม SELECT * ; ใช้ SET NOCOUNT ON
   จากนั้นเขียนบล็อกเรียกใช้กับ ProductID 854 และพิมพ์ ReturnCode + OUTPUT
*/
-- TODO: CREATE OR ALTER PROCEDURE Sales.usp_GetMiniProductStock ...
GO

-- TODO: DECLARE ... EXEC ... SELECT ReturnCode, ProductName, Quantity
GO

/* ==========================================================================
   Exercise 3 — Error handling ใน Procedure
   ==========================================================================
   TODO: สร้าง Sales.usp_SetMiniProductQty
   - รับ @ProductID, @NewQty
   - ถ้า @NewQty < 0 ให้ THROW 50020 พร้อมข้อความภาษาไทย/อังกฤษที่ชัดเจน
     (ก่อนอัปเดต — ไม่ต้องพึ่ง CHECK constraint)
   - UPDATE Quantity
   - ถ้า @@ROWCOUNT = 0 ให้ THROW 50021 (not found)
   - ห่อด้วย TRY/CATCH: ROLLBACK ถ้ามี transaction, เรียก dbo.usp_LogError, แล้ว THROW ต่อ
*/
-- TODO: CREATE OR ALTER PROCEDURE Sales.usp_SetMiniProductQty ...
GO

-- TODO: ทดสอบเคสสำเร็จ + เคส @NewQty < 0 (ดู dbo.ErrorLog)
GO

/* ==========================================================================
   Exercise 4 — Nested Procedure + Parameter Sniffing mitigation
   ==========================================================================
   TODO A: สร้าง Sales.usp_GetActiveCustomerName(@CustID, @Name OUTPUT)
           แล้วสร้าง Sales.usp_GreetCustomer(@CustID) ที่เรียกตัวแรกแบบ nested

   TODO B: สร้าง Sales.usp_CountOrdersByProduct(@ProductID)
           ที่นับจำนวนแถวใน Sales.SalesOrderDetail ตาม ProductID
           และใช้ mitigation อย่างน้อย 1 แบบ (LOCAL VAR หรือ OPTION (RECOMPILE))
           พร้อมคอมเมนต์อธิบายว่าทำไมเลือกแบบนั้น
*/
-- TODO: nested procedures
GO

-- TODO: sniffing mitigation procedure
GO

/* ==========================================================================
   Exercise 5 — OUTPUT INSERTED
   ==========================================================================
   TODO:
   - INSERT 1 แถวเข้า Sales.MiniOrders (CustID = 2, PO = N'EX05-OUTPUT', Freight = 1)
   - ใช้ OUTPUT inserted.OrderID, inserted.CustID INTO ตัวแปรตาราง @Out
   - SELECT จาก @Out แสดง OrderID ที่ได้
   - แล้ว DELETE แถวที่สร้าง (cleanup) โดยใช้ OrderID จาก @Out
   ห้ามใช้ SCOPE_IDENTITY() ในข้อนี้
*/
-- TODO
GO

/* ==========================================================================
   Exercise 6 — TVP
   ==========================================================================
   TODO:
   - สร้าง TYPE Sales.OrderLineType (ถ้ายังไม่มี) คอลัมน์ ProductID, Quantity, UnitPrice, Discount
   - สร้าง Sales.usp_SumOrderLines(@Lines Sales.OrderLineType READONLY)
     คืนผลรวม LineTotal = SUM(Quantity * UnitPrice * (1 - Discount)) เป็น SELECT แถวเดียว
   - ทดสอบด้วย 2–3 บรรทัดสินค้า 854/859/860
*/
-- TODO: TYPE + PROCEDURE + EXEC test
GO
