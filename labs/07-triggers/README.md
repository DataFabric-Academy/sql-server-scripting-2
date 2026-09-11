# Lab 07 — DML Triggers

**PPT:** โมดูล 7 · สไลด์ **91–105** · Nested/Recursive 102–103 · ทางเลือก 105

## Scenario

ธุรกิจอยาก Soft-delete ออเดอร์และเก็บ audit อัตโนมัติเมื่อมีการ INSERT/UPDATE  
มีคนเสนอ Trigger ทุกอย่าง — รวมงานที่ Constraints/Default/FK ทำได้อยู่แล้ว  
ให้สร้าง Trigger ที่จำเป็นจริง และรู้ว่าเมื่อไร **ไม่ควร** ใช้

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบาย AFTER vs INSTEAD OF และบทบาท `inserted`/`deleted` |
| 2 | สร้าง AFTER INSERT/UPDATE/DELETE และ INSTEAD OF soft-delete ได้ |
| 3 | อธิบาย Nested/Recursive/`sp_settriggerorder` และเลือกทางเลือกแทน Trigger (สไลด์ 105) รวม REGEXP ใน CHECK บน 2025 |

## เวลา / Prerequisites

**80–90 นาที** · Lab 05–06 · Mini*

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | AFTER / INSTEAD OF / nested notes / `SET NOCOUNT ON` |
| 2 | `exercise.sql` | ผู้เรียน |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. Trigger ทำงาน **ต่อ statement** — เขียน set-based จาก `inserted`/`deleted`  
2. `SET NOCOUNT ON` สำคัญต่อ client ที่อ่าน rowcount  
3. Nested default ON, Recursive default OFF — ทดสอบ nesting ≤ 32  
4. Constraints / Defaults / FK / Computed / Indexed views มาก่อน Trigger  
5. DDL Triggers กล่าวสั้น (สไลด์ 92) — ไม่ลงมือลึกในคลาสนี้

## Takeaways

- Trigger = ปฏิกิริยาต่อเหตุการณ์ — ไม่ใช่ที่ซ่อน business logic ทั้งหมด  
- Workshop Day 2 จะใช้ soft-delete + audit เป็นชิ้นส่วน API Layer
