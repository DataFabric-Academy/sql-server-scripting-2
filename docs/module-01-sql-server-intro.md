# โมดูล 1 — สิ่งที่ควรทราบก่อนใช้งาน Microsoft SQL Server

สอดคล้องสไลด์ **13–18** ของ SQL-PG-SP Version 5  
อัปเดตบริบท engine: **SQL Server 2025 (17.x) / Compatibility Level 170**  
รายละเอียดฟีเจอร์: [`sql-server-2025.md`](sql-server-2025.md)

ใช้พูดเปิด Day 1 (~10–15 นาที) — ไม่มี `exercise.sql` แยก

## จุดสอนตามสไลด์

| สไลด์ | หัวข้อ | สาระสั้น (อัปเดต 2025) |
|------:|--------|------------------------|
| 14 | สถาปัตยกรรม | Query Processor · Database Engine · SQLOS |
| 15 | องค์ประกอบ | Engine, SSIS / SSAS / SSRS, MDS / DQS |
| 16 | เวอร์ชัน / Compatibility Level | **2022 → 160**, **2025 → 170** (คลาสแนะนำ 2025 + compat 170) |
| 17 | SSMS | **SSMS 22** เป็นเครื่องมือหลัก |
| 18 | SSDT / Project | `Microsoft.Build.Sql` + Database DevOps ใน SSMS 22 |

## สคริปต์ตรวจสภาพแวดล้อม (รันตอนเปิดคลาส)

```sql
SELECT
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('Edition') AS Edition,
    name,
    compatibility_level,
    is_read_committed_snapshot_on,
    is_accelerated_database_recovery_on,
    is_optimized_locking_on
FROM sys.databases
WHERE name = DB_NAME();
```

## Checkpoint

ผู้เรียนชี้ได้ว่า:

1. สคริปต์ Lab รันที่ **Database Engine** ผ่าน SSMS
2. Compatibility Level มีผลต่อ optimizer / ฟีเจอร์ภาษา (เช่น REGEXP บางตัวต้อง 170)
3. SQL Server 2025 เพิ่มกลไก concurrency/perf (Optimized locking, OPPO, PSP-for-DML) ที่จะพูดต่อใน Lab 04–06
4. Schema-as-code (`.sqlproj`) ต่างจากสคริปต์ pedagogy ใน `labs/`
