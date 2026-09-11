# Lab 01 — Language Elements & Scripting

**PPT:** โมดูล 2 (ส่วนต้น) · สไลด์ **20–35** · [`slide-mapping.md`](../../docs/slide-mapping.md)

## Scenario

ทีมเริ่มเขียนสคริปต์สั่งซื้อบน Mini* แต่โค้ดกระจัดกระจาย: ตัวแปรหายหลัง `GO`, เงื่อนไข `NULL` ผิด, loop ตัดสต็อกไม่ครบ  
ก่อนสร้าง Stored Procedure ต้องทำให้ **batch / flow / temp storage** ทำงานตามที่ตั้งใจ

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบาย Batch/`GO`, scope ของตัวแปร, comment, expression ได้ |
| 2 | ใช้ `IF` / `WHILE` (+ `BREAK`/`CONTINUE`) และ predicate `IS NULL` ได้ถูกต้อง |
| 3 | เลือก table variable vs `#temp` ตามงาน (สไลด์ 25–27) |

## เวลา / Prerequisites

**45–60 นาที** · รัน `setup/` แล้ว · พื้นฐาน `SELECT`/`JOIN`

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | Instructor รันทีละ section (รวม optional `REGEXP_*` บน compat 170) |
| 2 | `exercise.sql` | ผู้เรียนทำ TODO 1–4 |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. `GO` ไม่ใช่ T-SQL — ตัวแปรไม่ข้าม batch  
2. `WHERE col = NULL` ได้ 0 แถวเสมอ → ใช้ `IS NULL`  
3. Table variable ประมาณ cardinality ต่ำ; `#temp` มี statistics / ใช้ข้าม batch ได้  
4. บนสไลด์ตัวอย่างใช้ `Sales.SalesOrderHeader` — lab ใช้ทั้ง AdventureWorks และ Mini*

## Takeaways

- Flow control ใน T-SQL เหมาะกับ orchestration เบา ๆ — logic ธุรกิจจริงไป Lab 02–05  
- SQL Server 2025: มี `REGEXP_*` เป็น system function ใหม่ (compat 170)
