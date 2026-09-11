# SQL Server 2025 Alignment Notes (SQL-PG-SP)

เอกสารนี้สรุปสิ่งที่คอร์สต้องสอน/อ้างอิงให้สอดคล้องกับ **SQL Server 2025 (17.x)** และ **Compatibility Level 170**  
อ้างอิงหลัก: [What's new in SQL Server 2025](https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2025), [Intelligent Query Processing](https://learn.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing), [Optimized locking](https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking)

## เป้าหมายเวอร์ชันในคลาส

| รายการ | ค่าแนะนำ |
|--------|----------|
| Engine | **SQL Server 2025** (Developer) — รองรับ 2022 เป็นขั้นต่ำสำหรับ lab พื้นฐาน |
| Compatibility Level | **170** สำหรับ AdventureWorks / SqlPgSpLab เมื่อสาธิตฟีเจอร์ 2025 |
| SSMS | **SSMS 22** (+ Database DevOps ถ้าใช้ `.sqlproj`) |
| Sample DB | AdventureWorks2022 (หรือใหม่กว่าถ้ามี) บน instance 2025 |

ตรวจเวอร์ชัน:

```sql
SELECT
    @@VERSION AS EngineVersion,
    name,
    compatibility_level,
    is_read_committed_snapshot_on,
    is_accelerated_database_recovery_on,
    is_optimized_locking_on
FROM sys.databases
WHERE name = DB_NAME();
```

ตั้ง compat 170 (หลังทดสอบแล้ว):

```sql
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 170;
```

## แมปฟีเจอร์ 2025 → โมดูลคอร์ส

| โมดูลคอร์ส | ฟีเจอร์ / พฤติกรรมที่เกี่ยวกับ 2025 | Lab ที่ควรพูด |
|------------|-------------------------------------|----------------|
| Intro / Version | Compatibility **170**, product 17.x | `docs/module-01-sql-server-intro.md` |
| T-SQL Language | Native **REGEXP_*** (บางฟังก์ชันต้อง compat 170) | Lab 01 (ภาพรวม) / optional demo |
| Error Handling | CLR/Managed ยังใช้ได้ แต่ REGEXP ลดความจำเป็นของ CLR regex | Lab 02 (สไลด์ 45) |
| Transaction | ADR ใน **tempdb** (ผลกับ `#temp`) | Lab 01/03 (สั้น) |
| Concurrency | **Optimized locking** (TID + LAQ), ต้อง ADR; LAQ ได้ประโยชน์เต็มเมื่อมี **RCSI** | Lab 04 |
| Stored Procedures | **PSP สำหรับ DML** (compat 170), **OPPO** (optional NULL params), `OPTIMIZED_SP_EXECUTESQL` | Lab 05 |
| Functions | Scalar UDF **Inlining** (ตั้งแต่ 2019/compat 150, ยังสำคัญใน 2025), Interleaved execution สำหรับ mTVF | Lab 06 |
| Triggers | ไม่มี breaking ใหญ่เรื่อง DML trigger — ย้ำว่า Optimized locking ลดแถว lock ของ DML ที่ยิง trigger | Lab 07 |

## สาระสำคัญที่ Instructor ควรพูด

### 1) Optimized Locking (Concurrency)

- มีใน SQL Server 2025 — **ปิดเป็นค่าเริ่มต้น** บน on-prem (เปิดต่อ database ได้)
- องค์ประกอบ: **TID locking** + **Lock after qualification (LAQ)**
- ต้องเปิด **ADR** ก่อน; ได้ประโยชน์สูงสุดเมื่อเปิด **RCSI**
- ผลต่อคลาส: demo blocking แบบคลาสสิกอาจ “เบากว่า” ถ้าเปิด optimized locking — บอกผู้เรียนให้ตรวจ `is_optimized_locking_on`

```sql
-- ตัวอย่างเปิด (ต้องมี ADR ก่อน)
-- ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = ON;
-- ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
-- ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = ON;
```

เอกสาร: [Optimized locking](https://learn.microsoft.com/en-us/sql/relational-databases/performance/optimized-locking)

### 2) Parameter Sniffing ในยุค 2025 (Stored Procedures)

แนวทาง mitigation เดิมยังสอนได้ (`RECOMPILE`, `OPTIMIZE FOR`, local variable)  
เพิ่มบริบท 2025 / compat 170:

| ฟีเจอร์ | สาระ |
|---------|------|
| **PSP Optimization** | จากเดิมช่วย SELECT → ใน 2025 ขยายไป **INSERT/UPDATE/DELETE/MERGE** ที่ compat 170 |
| **OPPO** | แยก plan ตามพารามิเตอร์ที่เป็น `NULL` vs `NOT NULL` (optional filter pattern) |
| **OPTIMIZED_SP_EXECUTESQL** | ลด compilation storm ของ dynamic SQL ผ่าน `sp_executesql` |

เอกสาร: [IQP](https://learn.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing)

### 3) Functions / IQP

- **Scalar UDF Inlining** (compat ≥ 150): scalar ที่เข้าเงื่อนไขถูก inline เข้า query — สอนคู่กับข้อควรระวังว่า “scalar ช้าเสมอ” ไม่ Absolute อีกต่อไปบน 2019+
- ยังแนะนำ **Inline TVF** เป็นค่าเริ่มต้นเมื่อคืนตาราง
- สไลด์ IQP (ประมาณสไลด์ 84–85) ให้อัปเดตคำพูดเป็น “2019 Inlining + 2022 PSP + **2025 OPPO / PSP-for-DML**”

เอกสาร: [Scalar UDF inlining](https://learn.microsoft.com/en-us/sql/relational-databases/user-defined-functions/scalar-udf-inlining)

### 4) REGEXP (Language / Validation)

SQL Server 2025 มีฟังก์ชัน regex พื้นเมือง เช่น `REGEXP_LIKE`, `REGEXP_REPLACE`, `REGEXP_SUBSTR`, `REGEXP_INSTR`, `REGEXP_COUNT`, และ TVF `REGEXP_MATCHES` / `REGEXP_SPLIT_TO_TABLE`  
บางตัวต้อง **compat 170**

ใช้ในคลาสเป็น:

- ตัวอย่าง System Function ใหม่ (Lab 01)
- ทางเลือกแทน CLR regex / validation ใน Trigger หรือ CHECK (Lab 07 สไลด์ 105)

อ้างอิง: [Azure SQL Dev Blog — Regex](https://devblogs.microsoft.com/azure-sql/unlocking-the-power-of-regex-in-sql-server/)

### 5) Tempdb / `#temp`

- **ADR in tempdb** และ tempdb space governance ใน 2025 — เกี่ยวกับ Lab ที่ใช้ temporary table หนัก ๆ
- ยังคงสอนว่า `#temp` มี statistics แต่บอกว่า engine 2025 จัดการ recovery/space ของ tempdb ได้ดีขึ้น

## สิ่งที่ยังไม่เปลี่ยน (สอนเหมือนเดิม)

- พื้นฐาน Batch / Flow / TRY-CATCH / THROW
- ACID, Explicit transaction, `XACT_ABORT`, `XACT_STATE`
- ปัญหา Dirty / Lost update / Non-repeatable / Phantom / Double read (ทฤษฎี)
- โครง CREATE PROC / FUNCTION / TRIGGER
- AFTER vs INSTEAD OF, Nested / Recursive triggers

## Lab checklist เมื่อรันบน SQL Server 2025

1. ตรวจ `compatibility_level` และฟิลด์ `is_optimized_locking_on`
2. Lab 04: ถ้า blocking “ไม่รุนแรงแบบเดิม” ให้เช็ก Optimized locking / RCSI
3. Lab 05: หลังสอน mitigation แบบ manual ค่อยพูด PSP/OPPO เป็น “engine-side help”
4. Lab 06: โชว์ plan ว่า Scalar ถูก Inline หรือไม่ (`is_inlineable` / actual plan)
5. Optional: demo `REGEXP_LIKE` สั้น ๆ เมื่อ compat = 170
