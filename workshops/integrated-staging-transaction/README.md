# Workshop — Integrated Staging Pattern

**เส้นเรื่อง:** สืบค้น → `#temp` → ตรวจสอบ → Transaction ปรับปรุงข้อมูลจริง → สร้างเป็น Procedure  
รวบ best practice จาก Lab 01–03 (และเตรียมต่อ Lab 05)

## Scenario

คลังจริง (`Production.ProductInventory`) มียอดรวมต่อสินค้า แต่ตารางธุรกิจ `Production.MiniProducts` ใช้เป็นสต็อกสำหรับระบบสั่งซื้อ  
ทุกเช้าต้อง **ดึงสินค้าที่สต็อกต่ำกว่าเกณฑ์** มาจัดคิวใน temp แล้ว **อัปเดต MiniProducts ให้ถึงจุดเติม** ภายใต้ transaction เดียว  
ถ้าขั้นตอนใดพัง ต้องไม่เหลือการอัปเดตครึ่ง ๆ และต้องมีบันทึก error

## Skill Progression

| ระดับ | ทักษะ |
|------:|--------|
| 1 | เขียน `SELECT … INTO #temp` / `INSERT #temp` จากหลายตารางได้ |
| 2 | ตรวจ/กรองใน `#temp` แล้วอัปเดตตารางจริงใน `TRY/CATCH` + `XACT_ABORT` |
| 3 | ใช้ `OUTPUT` เก็บผลต่างก่อน–หลัง และห่อเป็น `usp_…` ที่เรียกซ้ำได้ |

## Best Practice Checklist (ต้องเห็นในตัวอย่าง)

| หัวข้อ | ที่ใช้ |
|--------|--------|
| Qualify names | `Production.MiniProducts`, `dbo.ErrorLog` |
| `#temp` (ไม่ใช่ table variable) | งานหลายขั้น + ต้องการ index/statistics |
| `SET NOCOUNT ON` | ใน procedure |
| `SET XACT_ABORT ON` | คู่กับ explicit transaction |
| `TRY/CATCH` + `XACT_STATE()` | rollback ถูกต้อง |
| `THROW` / `usp_LogError` | error ที่อ่านรู้เรื่อง + log |
| `UPDLOCK, ROWLOCK` | อ่านแถวที่จะอัปเดต |
| `OUTPUT inserted/deleted` | เก็บหลักฐานการเปลี่ยนแปลง |
| ห้าม partial update | ทุกอย่างใน transaction เดียว |

## เวลา / Prerequisites

**45–60 นาที** · หลัง Lab 01–03 (แนะนำก่อนหรือหลัง Workshop Place Order)  
ต้องรัน `setup/01-create-lab-objects.sql` แล้ว

## Steps

| ลำดับ | ไฟล์ | ผู้ใช้ |
|------:|------|--------|
| 1 | `demo.sql` | Instructor — เดินทีละเฟส A→E |
| 2 | `exercise.sql` | ผู้เรียนทำ TODO แล้วห่อเป็น procedure |
| 3 | `solution.sql` | เฉลยเต็ม + procedure |
| 4 | `acceptance-tests.sql` | ตรวจว่าผ่าน |

## Takeaways

- `#temp` = staging area ของ script; ตารางจริงแก้อยู่ใน transaction เท่านั้น  
- Pattern นี้คือสะพานจาก “สคริปต์สำรวจ” ไป “object ที่แอปเรียกซ้ำได้”
