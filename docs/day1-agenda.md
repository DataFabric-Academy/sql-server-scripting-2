# Day 1 Agenda — ตาม PPT โมดูล 1–4

**เวลา:** 09:00 – 16:00  
**สไลด์หลัก:** 13–59 (+ Note ว่างสำหรับจด)  
**เป้าหมาย:** Scripting + Error + Transaction + Concurrency ตาม TOC Version 5

| เวลา | โมดูล PPT | สไลด์ | กิจกรรม | โฟลเดอร์ |
|------|-----------|------:|---------|----------|
| 09:00 – 09:20 | Setup | — | SSMS 22, AdventureWorks, รัน `setup/` + ตรวจ compat/2025 flags | `setup/` · `docs/sql-server-2025.md` |
| 09:20 – 09:35 | 1. ก่อนใช้งาน SQL Server | 13–18 | Architecture / **compat 170** / SSMS–SSDT | `docs/module-01-sql-server-intro.md` |
| 09:35 – 10:25 | 2a. T-SQL Language Elements | 20–35 | Demo + Exercise | `labs/01-language-elements` |
| 10:25 – 10:40 | พัก | | | |
| 10:40 – 11:40 | 2b. Error Handling *(ในโมดูล 2 ของ PPT)* | 36–45 | RAISERROR / THROW / TRY-CATCH | `labs/02-error-handling` |
| 11:40 – 12:30 | 3. Transaction | 47–52 | Explicit, XACT_ABORT, สไลด์ **52** Mini* | `labs/03-transactions` |
| 12:30 – 13:30 | พักกลางวัน | | | |
| 13:30 – 14:10 | Pattern รวม | — | Query → `#temp` → TRAN + OUTPUT (best practice) | `workshops/integrated-staging-transaction` |
| 14:10 – 15:20 | 4. Concurrency | 54–59 | ปัญหา 5 แบบ + Isolation + สไลด์ **59** | `labs/04-concurrency` |
| 15:20 – 15:50 | Capstone Day 1 | — | `usp_PlaceOrder` (ต่อจากแพทเทิร์นสไลด์ 52) | `workshops/day1-order-processing` |
| 15:50 – 16:00 | สรุป + Note | 19/46/53/60 | Q&A | |

## Checkpoint ท้ายวัน

1. แยก Batch / Scope และใช้ IF / WHILE ได้  
2. ใช้ THROW / RAISERROR และ TRY/CATCH ได้  
3. ห่อ DML ด้วย Transaction + `XACT_ABORT` / `XACT_STATE` ตามแพทเทิร์นสไลด์ 52  
4. ใช้แพทเทิร์น สืบค้น → `#temp` → validate → TRAN อัปเดต (+ OUTPUT / ErrorLog) ได้  
5. อธิบาย Dirty / Lost update / Non-repeatable / Phantom / Double read และเลือก Isolation  
6. ส่ง Workshop Place Order ได้
