/*
================================================================================
  Lab 03 — exercise.sql  (ผู้เรียน)
  Transactions
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

-- รีเซ็ตสต็อกก่อนทำแบบฝึก
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID
                 WHEN 854 THEN 100
                 WHEN 859 THEN 50
                 WHEN 860 THEN 50
               END
WHERE ProductID IN (854, 859, 860);
GO

/*------------------------------------------------------------------------------
  TODO 1 — Explicit transaction พื้นฐาน
  ลด Quantity ของ ProductID 859 ลง 5 ชิ้น ใน BEGIN/COMMIT
  จากนั้นใน transaction ใหม่ ลดอีก 5 แล้ว ROLLBACK
  SELECT แสดง Quantity สุดท้ายของ 859 (ควรเป็น 95)
------------------------------------------------------------------------------*/
-- TODO 1: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 2 — สร้างออเดอร์แบบ atomic (สำเร็จ)
  ใช้ TRY/CATCH + XACT_ABORT ON + XACT_STATE()
  - INSERT MiniOrders ให้ CustID = 2, PO = N'EX-TODO2'
  - INSERT MiniOrderDetails: Product 854 qty 10, 860 qty 5
  - UPDATE ตัดสต็อกตามจำนวน
  - COMMIT
  ใน CATCH: ถ้า XACT_STATE() <> 0 ให้ ROLLBACK แล้ว THROW
------------------------------------------------------------------------------*/
-- TODO 2: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 3 — ออเดอร์ที่ต้องล้มเพราะสต็อกไม่พอ
  เหมือน TODO 2 แต่ PO = N'EX-TODO3' และพยายามตัด Product 854 จำนวน 100000
  ต้องไม่เหลือแถวใน MiniOrders / MiniOrderDetails ของ PO นี้
  และสต็อก 854 ต้องไม่เปลี่ยนจากค่าก่อนเริ่ม TODO 3
------------------------------------------------------------------------------*/
-- TODO 3: WRITE YOUR CODE HERE


GO

/*------------------------------------------------------------------------------
  TODO 4 — @@TRANCOUNT
  เปิด BEGIN TRAN สองชั้น (nested)
  PRINT @@TRANCOUNT หลังแต่ละชั้น
  COMMIT ชั้นใน แล้ว ROLLBACK ชั้นนอก
  อธิบายด้วย PRINT ว่าทำไมการเปลี่ยนแปลงในชั้นในไม่ถูก persist
------------------------------------------------------------------------------*/
-- TODO 4: WRITE YOUR CODE HERE


GO

PRINT N'===== Lab 03 exercise: ส่งงานเมื่อครบ TODO =====';
GO
