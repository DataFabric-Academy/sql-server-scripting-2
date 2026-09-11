# Lab 04 — Concurrency & Isolation Levels

**PPT:** โมดูล 4 · สไลด์ **54–59** · สไลด์ **56** = ปัญหา 5 แบบ · **59** = session isolation vs hint

## Scenario

ช่วงโปรโมชัน รายงานสต็อกและยอดสั่งซื้อ “เต้น” — คนหนึ่งเห็นตัวเลข อีกคนเห็นคนละค่า  
บางออเดอร์ตัดสต็อกชนกันจนสงสัย Lost update  
ให้พิสูจน์ปัญหา concurrency ด้วย **2 sessions** แล้วเลือก Isolation (+ ระวัง Optimized Locking บน SQL Server 2025)

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบาย Dirty / Lost update / Non-repeatable / Phantom / Double read |
| 2 | สาธิตปัญหาด้วยคู่ session และอ่านผลของ Isolation Level ได้ |
| 3 | เลือก session-level vs `WITH (SERIALIZABLE)` ตามสไลด์ 59 และอธิบายผลของ Optimized Locking / RCSI |

> เจาะ Lock / Deadlock / DMV ลึก → [PT Module 05 Concurrency](https://github.com/DataFabric-Academy/sql-server-performance-tuning/tree/main/Module_05_Concurrency)

## เวลา / Prerequisites

**75–90 นาที** · Lab 03 · เปิด Query อย่างน้อย 2 หน้าต่าง · สิทธิ์เปิด SNAPSHOT ถ้าทำ session 05

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | Overview + ตรวจ `is_optimized_locking_on` |
| 2–6 | `sessions/*-s1.sql` + `*-s2.sql` | คู่ Session ตาม Step ในไฟล์ |
| 7 | `exercise.sql` → `solution.sql` | รวม Lost update / Double read / สไลด์ 59 |

### วิธีรันคู่ Session

1. เปิด 2 query windows → ทั้งคู่ `USE AdventureWorks;`  
2. ตาม `-- Step N` สลับ s1 ↔ s2  
3. จบด้วย `ROLLBACK` — **อย่า commit ค่าทดลอง**

## จุดที่ต้องสังเกต

| ปัญหา | กันด้วย (แนวทาง) |
|--------|-------------------|
| Dirty read | ≥ READ COMMITTED |
| Lost update | UPDLOCK / version / UPDATE มีเงื่อนไข |
| Non-repeatable | REPEATABLE READ / SNAPSHOT / SERIALIZABLE |
| Phantom | SERIALIZABLE / SNAPSHOT |
| Double read | SERIALIZABLE / ออกแบบ key-query |

**SQL Server 2025:** Optimized locking (TID + LAQ) อาจทำให้ blocking เบาลง — ตรวจก่อนสอน · [`sql-server-2025.md`](../../docs/sql-server-2025.md)

## Takeaways

- Isolation คือ trade-off ระหว่างความถูกต้องกับ throughput  
- เคสสต็อกมักต้องการมากกว่า READ COMMITTED อย่างเดียว
