# Lab 06 — Functions (Scalar / TVF)

**PPT:** โมดูล 6 · สไลด์ **75–89** · Deterministic 80 · Perf/IQP 84–86 · เทียบ SP 89

## Scenario

รายงานต้องการ “ยอดสรุปต่อลูกค้า” และ “ถัง Freight” ใน `SELECT`  
มีคนเสนอ Scalar UDF ทุกคอลัมน์ — รายงานช้าลงชัด  
ให้เลือกชนิด Function ให้ถูก และรู้ว่าเมื่อไรควรเป็น Inline TVF หรือย้ายไป Stored Procedure

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | แยก Scalar / Inline TVF / Multi-statement TVF + ข้อจำกัด (ห้าม side-effect DML, ไม่มี TRY/CATCH ใน function) |
| 2 | สร้าง Scalar และ Inline TVF ใช้งานจริงบน Mini* ได้ |
| 3 | อธิบาย Deterministic, ผลกระทบ perf, Scalar UDF Inlining (compat ≥ 150) และเลือกทางเลือกแทน scalar ใน SELECT |

> Execution plan / IQP เชิงลึก → [PT Module 07 Query Execution](https://github.com/DataFabric-Academy/sql-server-performance-tuning/tree/main/Module_07_Query_Execution)

## เวลา / Prerequisites

**70–80 นาที** · Lab 05

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | เทียบชนิด + STATISTICS + ตรวจ `is_inlineable` |
| 2 | `exercise.sql` | รวมข้อ Deterministic (สไลด์ 80) |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. Function **ห้าม** แก้ข้อมูลตาราง และไม่มี Exception Handling แบบ procedure  
2. Inline TVF ≈ parameterized view — optimizer รวมกับ query ได้ดี  
3. mTVF / Scalar อาจไม่ถูก expand — ระวังใน `SELECT`/`WHERE`/`CROSS APPLY` ซ้ำ ๆ  
4. SQL Server 2019+/2025: Scalar ที่เข้าเงื่อนไขอาจถูก **Inline** — ตรวจ plan ก่อนสรุปว่าช้าเสมอ

## Takeaways

- คืนตาราง → เริ่มที่ Inline TVF  
- ต้อง DML / error handling / multi result set → Stored Procedure (สไลด์ 89)
