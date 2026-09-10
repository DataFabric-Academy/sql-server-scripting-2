# Day 1 Agenda — Scripting, Transaction & Concurrency

**เวลา:** 09:00 – 16:00 (รวมพักประมาณ 1 ชม.)  
**เป้าหมายวัน:** ผู้เรียนเขียน Script ที่ควบคุม Flow / Error / Transaction ได้ และอธิบาย Isolation Level ได้

| เวลา | หัวข้อ | กิจกรรม | โฟลเดอร์ |
|------|--------|---------|----------|
| 09:00 – 09:20 | เปิดคอร์ส + Setup | ตรวจ SSMS, AdventureWorks, รัน setup | `setup/` |
| 09:20 – 10:20 | T-SQL Language Elements | Demo + Exercise | `labs/01-language-elements` |
| 10:20 – 10:35 | พัก | | |
| 10:35 – 11:35 | Error Handling | RAISERROR/THROW, TRY/CATCH | `labs/02-error-handling` |
| 11:35 – 12:30 | Transaction | Explicit, XACT_ABORT, XACT_STATE | `labs/03-transactions` |
| 12:30 – 13:30 | พักกลางวัน | | |
| 13:30 – 14:45 | Concurrency & Isolation | Session labs คู่ (รวม SNAPSHOT) | `labs/04-concurrency` |
| 14:45 – 15:00 | พัก | | |
| 15:00 – 15:50 | Workshop: Place Order | ทำ `usp_PlaceOrder` | `workshops/day1-order-processing` |
| 15:50 – 16:00 | สรุป Day 1 + Q&A | | |

## Checkpoint ท้ายวัน

ผู้เรียนควรทำได้:

1. แยก Batch / Scope และใช้ IF / WHILE อย่างถูกต้อง
2. เลือก THROW หรือ RAISERROR ตามบริบท และดัก Error ด้วย TRY/CATCH
3. ห่อ DML ด้วย Transaction + จัดการ rollback เมื่อเกิด error
4. อธิบาย Dirty / Non-repeatable / Phantom Read และผลของ Isolation Level
5. ส่ง Workshop Place Order ที่ atomic และตรวจสอบสต็อกได้
