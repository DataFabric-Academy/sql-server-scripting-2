# Lab 01 — Language Elements & Scripting

## วัตถุประสงค์

เข้าใจองค์ประกอบพื้นฐานของ T-SQL Script ที่จำเป็นก่อนเขียน Stored Procedure:

- Operators / Variables / Expressions
- Batch vs `GO` และขอบเขตตัวแปร (scope)
- Flow control: `IF/ELSE`, `WHILE` (`BREAK` / `CONTINUE`)
- Table variable vs Temporary table
- Predicate pitfalls (`= NULL`)
- Comments และการจัดโครงสร้างสคริปต์

## ระยะเวลาประมาณ

**45–60 นาที** (demo ~25 นาที + exercise ~20–30 นาที)

## Prerequisites

- รัน `setup/01-create-lab-objects.sql` แล้ว
- เชื่อมต่อ AdventureWorks (หรือ AdventureWorks2022) ใน SSMS
- พื้นฐาน `SELECT` / `JOIN` / `WHERE`

## ลำดับการรันไฟล์

| ลำดับ | ไฟล์ | ผู้ใช้ |
|------:|------|--------|
| 1 | `demo.sql` | Instructor — อธิบายทีละส่วน ตาม section header |
| 2 | `exercise.sql` | ผู้เรียน — ทำ TODO ทั้ง 4 ข้อ |
| 3 | `solution.sql` | เฉลยหลังทำเสร็จ / ทบทวน |

## จุดที่ต้องสังเกต

1. **`GO` ไม่ใช่ T-SQL** — เป็น client batch separator ของ SSMS; ตัวแปร `DECLARE` ไม่ข้าม batch
2. **`WHERE col = NULL` ได้ 0 แถวเสมอ** — ต้องใช้ `IS NULL` / `IS NOT NULL`
3. **Table variable** — cardinality estimate มักต่ำ (ประมาณ 1 แถวในแผนเก่า); ไม่มีสถิติแบบ temp table
4. **Temp table (`#`)** — อยู่ได้ข้าม batch ใน session เดียวกัน; มีสถิติ และรองรับ index ได้ยืดหยุ่นกว่า
5. **`BREAK` vs `CONTINUE`** — ออกจาก loop ทั้งก้อน vs ข้ามไปรอบถัดไป

## Key Takeaways

- แยก batch ด้วย `GO` เมื่อต้องสร้าง object หรือรีเซ็ต scope
- เลือก table variable เมื่อชุดข้อมูลเล็ก/สั้นอายุ; ใช้ temp table เมื่อต้องการสถิติ / index / ใช้ข้าม batch
- Predicate กับ `NULL` ต้องระวังเสมอใน production code
- Flow control ใน T-SQL เหมาะกับ orchestration เบา ๆ — logic ซับซ้อนควรอยู่ใน procedure พร้อม error handling (lab ถัดไป)
