# Workshop Day 1 — Order Processing

**Capstone หลัง Lab 03–04** · PPT โมดูล 3–4 (สไลด์ 47–59) · แพทเทิร์นสไลด์ **52**

## Scenario

ฝ่ายขายเปิดแคมเปญสั่งซื้อออนไลน์ — แอปต้องเรียก API ในฐานข้อมูลเพื่อวางออเดอร์  
ถ้าตัดสต็อกไม่พอหรือลูกค้าปิดใช้งาน ต้อง **ไม่เหลือออเดอร์ค้างครึ่ง ๆ** และต้องได้ error ที่ทีมซัพพอร์ตอ่านรู้เรื่อง

คุณต้องสร้าง `Sales.usp_PlaceOrder`

## Skill Progression

| ระดับ | ทักษะที่พิสูจน์ใน workshop นี้ |
|------:|--------------------------------|
| 1 | รวม validation + `THROW` รหัสชัด |
| 2 | Multi-table DML ใน transaction เดียวกับ `XACT_ABORT` / `XACT_STATE` |
| 3 | Log ลง `ErrorLog` แล้ว rethrow โดยไม่ทิ้ง partial data |

## Timebox

| ช่วง | เวลา |
|------|------|
| อ่านโจทย์ + ออกแบบ | 10 นาที |
| ลงมือ `starter.sql` | 35–40 นาที |
| เทียบ `solution.sql` | 10–15 นาที |
| **รวม** | **~60 นาที** |

## Acceptance Criteria

| # | เงื่อนไข |
|---|----------|
| 1 | รับอย่างน้อย: `@CustID`, `@ProductID`, `@Quantity`, `@UnitPrice`, `@OrderID OUTPUT` |
| 2 | ลูกค้าต้องมีและ `IsActive = 1` — ไม่ผ่าน `THROW` (เช่น 51001) |
| 3 | สต็อก `Quantity >= @Quantity` — ไม่พอ `THROW` (เช่น 51002) |
| 4 | ใน transaction เดียว: INSERT order + detail + UPDATE ลดสต็อก |
| 5 | สำเร็จแล้วเซ็ต `@OrderID` |
| 6 | Error → rollback ทั้งก้อน ไม่ทิ้ง partial data |
| 7 | (แนะนำ) `usp_LogError` ใน CATCH ก่อน `THROW` |

## ข้อมูลทดสอบ

- Customers: `CustID` 1–3  
- Products: `854` / `859` / `860` (ดู Quantity หลัง setup)

## Hints

1. `SET NOCOUNT ON; SET XACT_ABORT ON;`  
2. Validate ก่อน DML  
3. Optional: `UPDLOCK, ROWLOCK` ตอนอ่านสต็อก  
4. `SCOPE_IDENTITY()` / `OUTPUT INSERTED`  
5. CATCH: `IF XACT_STATE() <> 0 ROLLBACK;` → `usp_LogError` → `THROW;`

## Steps

1. เปิด `starter.sql`  
2. เติม TODO  
3. เทียบ `solution.sql`

## Prerequisites

Day 1 labs 01–04 · `setup/01-create-lab-objects.sql`
