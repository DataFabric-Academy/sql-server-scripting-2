# Day 2 Agenda — Procedures, Functions & Triggers

**เวลา:** 09:00 – 16:00 (รวมพักประมาณ 1 ชม.)  
**เป้าหมายวัน:** ออกแบบและสร้าง Stored Procedure / Function / Trigger พร้อมคำนึงถึง Security และ Performance

| เวลา | หัวข้อ | กิจกรรม | โฟลเดอร์ |
|------|--------|---------|----------|
| 09:00 – 09:15 | ทบทวน Day 1 | Quick quiz / แก้ Workshop ค้าง | |
| 09:15 – 10:45 | Stored Procedures | Parameters, Error Log, Security, Parameter Sniffing | `labs/05-stored-procedures` |
| 10:45 – 11:00 | พัก | | |
| 11:00 – 12:15 | Functions | Scalar / iTVF / mTVF + Performance | `labs/06-functions` |
| 12:15 – 13:15 | พักกลางวัน | | |
| 13:15 – 14:30 | DML Triggers | AFTER / INSTEAD OF / Nested / Recursive | `labs/07-triggers` |
| 14:30 – 14:45 | พัก | | |
| 14:45 – 15:30 | Workshop: API Layer | Proc + TVF + Trigger + GRANT EXECUTE | `workshops/day2-api-layer` |
| 15:30 – 15:50 | (ทางเลือก) Git + SQL Project | เปิด `SqlPgSp.sln` → Build/Publish `SqlPgSpLab` | `docs/ssms-git-and-sql-project.md` |
| 15:50 – 16:00 | สรุปคอร์ส + Road Map | | |

## Checkpoint ท้ายคอร์ส

ผู้เรียนควรทำได้:

1. ออกแบบ Stored Procedure ที่รับ parameter, จัดการ error, และควบคุม security context
2. อธิบาย Parameter Sniffing และเลือก mitigation ที่เหมาะสม
3. เลือกใช้ Scalar / Inline TVF / Multi-statement TVF โดยคำนึงถึง performance
4. สร้าง AFTER และ INSTEAD OF Trigger ได้ และระวัง Nested / Recursive
5. ส่ง Workshop API Layer ที่รวม Proc + Function + Trigger เป็นชุดใช้งานจริง
