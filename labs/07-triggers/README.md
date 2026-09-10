# Lab 07 — DML Triggers

## วัตถุประสงค์

1. สร้าง AFTER INSERT / UPDATE / DELETE และอ่าน pseudo-tables `inserted` / `deleted`
2. ใช้ `SET NOCOUNT ON`, `UPDATE()`, และเข้าใจ AFTER vs INSTEAD OF
3. สร้าง INSTEAD OF DELETE สำหรับ soft-delete
4. อธิบาย Nested / Recursive triggers และควบคุมลำดับด้วย `sp_settriggerorder`
5. รู้ข้อจำกัดด้าน performance และกรณีที่ **ไม่ควร** ใช้ trigger

## ระยะเวลาประมาณ

**80–90 นาที**

## Prerequisites

- Lab 05–06
- `setup/01-create-lab-objects.sql`
- Database: `AdventureWorks` หรือ `AdventureWorks2022`

## ลำดับการรันไฟล์

1. `demo.sql` (ใช้ตาราง Mini* + ตาราง audit ใน Sales)
2. `exercise.sql`
3. `solution.sql`

## AFTER vs INSTEAD OF

| | AFTER | INSTEAD OF |
|--|-------|------------|
| เวลาทำงาน | หลัง DML สำเร็จ (ก่อน commit ของ statement) | แทนที่ DML |
| ใช้กับ | Table | Table หรือ View |
| เคสเด่น | Audit, validation เพิ่มเติม, denormalize | Soft-delete, view ที่ไม่ updatable โดยตรง |
| ROLLBACK | ใช้ได้เพื่อยกเลิกทั้ง statement | ไม่ต้อง ROLLBACK ถ้าไม่ทำ DML จริง |

## จุดที่ต้องสังเกต

- Trigger ทำงาน **ต่อ statement** ไม่ใช่ต่อแถว — ต้องเขียนแบบ set-based จาก `inserted`/`deleted`
- `SET NOCOUNT ON` สำคัญมาก ไม่งั้น client อาจเห็น rowcount ของ trigger
- Nested triggers: trigger โยง DML ไปตารางอื่น → ยิง trigger ต่อ (ค่าเริ่มต้น ON)
- Recursive triggers: trigger บนตารางเดียวกันยิงตัวเอง (ค่าเริ่มต้น OFF ที่ระดับ database)
- `sp_settriggerorder` กำหนดได้แค่ first/last ของ AFTER ต่อ event — ตัวกลางไม่การันตีลำดับ

## เมื่อไหร่ไม่ควรใช้ Trigger

- Business workflow ยาว / เรียกบริการภายนอก
- Logic ที่แอปควรเป็นเจ้าของและทดสอบง่ายกว่า
- สิ่งที่ CHECK / FK / UNIQUE / indexed view ทำได้ชัดกว่า
- การซิงก์ข้อมูลข้ามระบบแบบ heavy (ใช้ queue / ETL แทน)

## Key Takeaways

- Trigger เหมาะกับ **invariant / audit / soft-delete** ที่ต้องบังคับที่ชั้นข้อมูล
- เขียน set-based เสมอ และระวัง recursion / สั่งซ้ำ
- วัด overhead — trigger ที่ซ่อนอยู่ทำให้ UPDATE ช้าโดยที่แอปไม่รู้
