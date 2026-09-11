/*
==============================================================================
 Workshop — Integrated Staging Pattern | EXERCISE
 Goal: สืบค้น → #temp → validate → TRAN อัปเดต MiniProducts → ห่อเป็น procedure

 Prerequisite: setup/01-create-lab-objects.sql
 Hint: ดู demo.sql ถ้าติด
==============================================================================
*/
USE AdventureWorks;
GO

/* --------------------------------------------------------------------------
   TODO 1 — สร้าง #RestockBatch และ INSERT จาก MiniProducts + ProductInventory
   เงื่อนไข: ProductID IN (854, 859, 860) และ Quantity < @LowStockThreshold
   คอลัมน์อย่างน้อย: ProductID, ProductName, MiniQty, InventoryQty, TargetQty, RestockQty, IsValid, RejectReason
   -------------------------------------------------------------------------- */
DECLARE @LowStockThreshold int = 40;
DECLARE @TargetQty         int = 50;

-- YOUR CODE HERE


/* --------------------------------------------------------------------------
   TODO 2 — Validate ใน #temp
   - RestockQty <= 0 → IsValid = 0
   - InventoryQty < TargetQty → IsValid = 0
   ถ้าไม่มีแถว valid ให้ THROW ก่อนเปิด transaction
   -------------------------------------------------------------------------- */

-- YOUR CODE HERE


/* --------------------------------------------------------------------------
   TODO 3 — BEGIN TRAN + UPDLOCK + UPDATE จาก #temp + OUTPUT + COMMIT
   ใช้ SET XACT_ABORT ON และ TRY/CATCH + XACT_STATE() + usp_LogError
   (สร้าง StockAdjustLog / usp_LogError ตาม demo ถ้ายังไม่มี)
   -------------------------------------------------------------------------- */

-- YOUR CODE HERE


/* --------------------------------------------------------------------------
   TODO 4 — ห่อเป็น Production.usp_RestockLowStock
   Parameters: @LowStockThreshold int, @TargetQty int, @ProductFilter (optional — หรือ hardcode 854/859/860)
   ภายใน procedure: SET NOCOUNT ON; pattern เต็มจาก TODO 1–3
   -------------------------------------------------------------------------- */

-- YOUR CODE HERE


/* --------------------------------------------------------------------------
   TODO 5 — เรียก procedure และตรวจ MiniProducts + StockAdjustLog
   -------------------------------------------------------------------------- */

-- YOUR CODE HERE
GO
