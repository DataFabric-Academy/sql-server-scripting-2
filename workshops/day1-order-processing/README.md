# Workshop Day 1 — Order Processing

## สถานการณ์ (Scenario)

ทีมขายต้องการ API ในฐานข้อมูลสำหรับ **วางออเดอร์แบบอะตอมมิก**:

1. ตรวจลูกค้าและสต็อกสินค้า
2. สร้างหัวออเดอร์ใน `Sales.MiniOrders`
3. สร้างรายละเอียดใน `Sales.MiniOrderDetails`
4. ลด `Production.MiniProducts.Quantity`
5. ถ้าขั้นตอนใดล้มเหลว → **ROLLBACK ทั้งก้อน** และโยน error ที่อ่านรู้เรื่อง

ผู้เรียนต้อง implement `Sales.usp_PlaceOrder`

## วัตถุประสงค์

- รวมความรู้ Transaction + Error Handling จาก Day 1 เป็น procedure ที่ใช้งานได้จริง
- ใช้ `TRY/CATCH` ร่วมกับ `XACT_ABORT` หรือตรวจ `XACT_STATE()` อย่างถูกต้อง
- เขียน validation + `THROW` ที่มีรหัส/ข้อความชัดเจน

## Timebox

| ช่วง | เวลา |
|------|------|
| อ่านโจทย์ + ออกแบบ | 10 นาที |
| ลงมือกับ `starter.sql` | 35–40 นาที |
| เทียบ `solution.sql` + อภิปราย | 10–15 นาที |
| **รวม** | **~60 นาที** |

## Acceptance Criteria

Procedure `Sales.usp_PlaceOrder` ต้อง:

| # | เงื่อนไข |
|---|----------|
| 1 | รับอย่างน้อย: `@CustID`, `@ProductID`, `@Quantity`, `@UnitPrice` และ `@OrderID OUTPUT` |
| 2 | ตรวจว่าลูกค้ามีอยู่และ `IsActive = 1` — ไม่ผ่านให้ `THROW` (เช่น 51001) |
| 3 | ตรวจสต็อก `MiniProducts.Quantity >= @Quantity` — ไม่พอให้ `THROW` (เช่น 51002) |
| 4 | ใน transaction เดียว: INSERT order + detail + UPDATE ลดสต็อก |
| 5 | สำเร็จแล้วเซ็ต `@OrderID` เป็น identity ของออเดอร์ใหม่ |
| 6 | เมื่อ error: rollback ให้ครบ และไม่ทิ้ง partial data |
| 7 | (แนะนำ) เรียก `dbo.usp_LogError` ใน CATCH ก่อน rethrow |

## ข้อมูลที่ใช้ทดสอบ

หลังรัน `setup/01-create-lab-objects.sql`:

- Customers: `CustID` 1–3
- Products ที่สต็อกพอ: `854` (50), `859` (40), `860` (30)

## Hints

1. เริ่ม `SET NOCOUNT ON; SET XACT_ABORT ON;`
2. Validate **ก่อน** หรือต้น TRY ก่อน DML
3. ใช้ `UPDLOCK, ROWLOCK` ตอนอ่านสต็อกถ้าต้องการกัน race แบบง่าย (optional)
4. `SCOPE_IDENTITY()` หรือ `OUTPUT INSERTED.OrderID` เพื่อได้ `@OrderID`
5. ใน CATCH: `IF XACT_STATE() <> 0 ROLLBACK;` แล้ว `EXEC dbo.usp_LogError;` ตามด้วย `THROW;`

## ลำดับไฟล์

1. `starter.sql` — scaffold + test harness
2. ผู้เรียนเติมส่วน TODO
3. เทียบ `solution.sql`

## Prerequisites

- Day 1 labs 01–04
- `setup/01-create-lab-objects.sql`
- Database: `AdventureWorks` / `AdventureWorks2022`
