# Lab 03 — Transactions

**PPT:** โมดูล 3 · สไลด์ **47–52** · Demo สำคัญสไลด์ **52** (Mini* + `XACT_ABORT` + `TRY/CATCH`)

## Scenario

พนักงานขายสร้างลูกค้า + ออเดอร์ + รายละเอียด + ตัดสต็อกในสคริปต์เดียว  
บางครั้งแทรกลูกค้าสำเร็จ แต่ตัดสต็อกพัง → ข้อมูลค้างครึ่ง ๆ  
ธุรกิจต้องการกฎ: **สำเร็จทั้งก้อน หรือไม่เหลือร่องรอย**

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบาย ACID และโหมด Auto / Explicit / Implicit |
| 2 | ใช้ `BEGIN`/`COMMIT`/`ROLLBACK` และอ่าน `@@TRANCOUNT` ได้ |
| 3 | ห่อ Multi-table DML ด้วย `XACT_ABORT` + `TRY/CATCH` + `XACT_STATE()` ตามแพทเทิร์นสไลด์ 52 |

## เวลา / Prerequisites

**60–75 นาที** · Lab 02 · Mini* จาก setup  

รีเซ็ตสต็อกเมื่อทดลองจนเพี้ยน:

```sql
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID WHEN 854 THEN 100 WHEN 859 THEN 50 WHEN 860 THEN 50 END
WHERE ProductID IN (854, 859, 860);
```

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | รวม SECTION แพทเทิร์นสไลด์ 52 (`SCOPE_IDENTITY` แทน `@@IDENTITY`) |
| 2 | `exercise.sql` | ออเดอร์ atomic + เคส rollback |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. Autocommit = default  
2. Nested `BEGIN TRAN` ไม่ใช่ nested true transaction — `ROLLBACK` เคลียร์ทั้งก้อน  
3. ไม่มี `XACT_ABORT`: error บางชนิดเหลือ transaction ค้าง  
4. `XACT_STATE()`: `1` / `0` / `-1` (uncommittable → ต้อง `ROLLBACK`)

## Takeaways

- งานหลายตารางที่ต้อง atomic → Explicit tran + `TRY/CATCH` + `XACT_ABORT ON`  
- แพทเทิร์นนี้คือหัวใจของ Workshop Day 1
