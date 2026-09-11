# Mapping สไลด์ PPT ↔ Labs (SQL-PG-SP Version 5)

อ้างอิง: `9Expert Training-SQL-PG-SP-Aj Phakkapong-Version 5`  
TOC สไลด์ **11** และ **107**

> สไลด์ **Note** (19, 46, 53, 60, 74, 90, 106) เป็นหน้าจดบันทึกว่าง — **ไม่ใช่โจทย์แบบฝึกหัด**  
> แบบฝึกหัดอยู่ใน `labs/*/exercise.sql` และ `workshops/` ของ repo นี้ โดยออกแบบให้ฝึกหลังจบกลุ่มสไลด์ของแต่ละโมดูล

## ตารางโมดูล

| โมดูล PPT | สไลด์ | Lab / เอกสารใน repo | หมายเหตุ |
|----------:|------:|---------------------|----------|
| 0. Cover / Roadmap | 1–10 | `docs/00-course-outline.md` | ไม่มี lab |
| 1. สิ่งที่ควรทราบก่อนใช้งาน SQL Server | **13–18** | `docs/module-01-sql-server-intro.md` + พูดใน Day1 เช้า | Architecture, Compatibility (ถึง 2025/170), SSMS, SSDT |
| — Note | 19 | — | หน้าจด |
| 2. องค์ประกอบภาษา T-SQL **รวม Error Handling** | **20–45** | `labs/01-language-elements` (**20–35**) + `labs/02-error-handling` (**36–45**) | แยก lab เพื่อจัดเวลาสอน แต่ตาม PPT เป็นโมดูลเดียว |
| — Note | 46 | — | หน้าจด |
| 3. การประกาศ Transaction | **47–52** | `labs/03-transactions` | Demo หลักสไลด์ **52** = Mini* + `XACT_ABORT` + `TRY/CATCH` |
| — Note | 53 | — | หน้าจด |
| 4. การควบคุมภาวะใช้งานพร้อมกัน | **54–59** | `labs/04-concurrency` | สไลด์ **56** มี Lost update / Double read; **59** = SERIALIZABLE vs hint |
| — Note | 60 | — | หน้าจด |
| 5. ออกแบบและสร้าง Stored Procedures | **61–73** | `labs/05-stored-procedures` | Sniffing 71, EXECUTE AS 72, ENCRYPTION 73 |
| — Note | 74 | — | หน้าจด |
| 6. ออกแบบและสร้าง Functions | **75–89** | `labs/06-functions` | Deterministic 80, Scalar/TVF perf 84–86, เทียบ SP 89 |
| — Note | 90 | — | หน้าจด |
| 7. ออกแบบและสร้าง Triggers | **91–105** | `labs/07-triggers` | DDL กล่าวใน 92; Nested/Recursive 102–103; ทางเลือก 105 |
| — Note | 106 | — | หน้าจด |
| TOC ท้าย / ปิด | 107–111 | — | |

## Capstone (repo เพิ่ม — ไม่มีเป็นโจทย์บนสไลด์)

| Workshop | หลังโมดูล | เหตุผล |
|----------|-----------|--------|
| `workshops/integrated-staging-transaction` | หลัง Lab 03 (ก่อน/คู่ Lab 04) | รวม Query → `#temp` → TRAN + best practice จาก Lab 01–03 |
| `workshops/day1-order-processing` | หลัง Lab 03–04 | รวม Transaction + Error เป็น `usp_PlaceOrder` ตามแพทเทิร์น Mini* บนสไลด์ 52 |
| `workshops/day2-api-layer` | หลัง Lab 05–07 | รวม Proc + Function + Trigger + Security |

## Lab checklist เมื่อรันบน SQL Server 2025

ดูรายละเอียดเต็ม: [`sql-server-2025.md`](sql-server-2025.md)

| Lab | จุดที่ต้องอัปเดตคำพูดบนสไลด์ Version 5 |
|-----|----------------------------------------|
| 01 | Compatibility **170**; แนะนำ REGEXP เป็น system function ใหม่ |
| 02 | CLR regex ยังมีได้ แต่ native REGEXP ลดความจำเป็น |
| 04 | **Optimized locking** (TID/LAQ) + ความสัมพันธ์กับ RCSI/ADR |
| 05 | Mitigation เดิม + **PSP for DML** / **OPPO** ที่ compat 170 |
| 06 | Scalar UDF Inlining + IQP 2022/2025 (ไม่ใช่แค่สไลด์เก่า) |

## แพทเทิร์นโค้ดบนสไลด์ที่ต้องสะท้อนใน lab

1. **MiniCustomers → MiniOrders → MiniOrderDetails → UPDATE MiniProducts** (สไลด์ 52, 59)
2. `SET XACT_ABORT ON` + `BEGIN TRY` / `BEGIN TRANSACTION` / `COMMIT` + `CATCH` ใช้ `XACT_STATE() = -1` → `ROLLBACK`
3. Isolation: ทั้งระดับ session (`SET TRANSACTION ISOLATION LEVEL …`) และระดับ statement (`WITH (SERIALIZABLE)`)
4. สไลด์ตัวอย่างอาจใช้ `@@IDENTITY` — ใน lab แนะนำ **`SCOPE_IDENTITY()`** เป็น best practice (อธิบายความต่างใน demo)
