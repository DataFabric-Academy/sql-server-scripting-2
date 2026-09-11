# SQL Server Programming — Stored Procedure

**คอร์ส 2 วัน (12 ชม.)** สำหรับสร้าง Database Programming ด้วย T-SQL  
อ้างอิงสไลด์: 9Expert SQL-PG-SP Version 5 · เว็บ: [9Expert Course](https://www.9experttraining.com/sql-server-programming-stored-procedure-training-course)

## เรื่องราวของคอร์สนี้

ทีมแอปต้องการ **API ชั้นฐานข้อมูล** สำหรับระบบสั่งซื้อบนตาราง Mini*  

| วัน | เรื่องที่ต้องพิสูจน์ได้ | ผลลัพธ์ |
|-----|------------------------|---------|
| **Day 1** | Script ควบคุม Flow / Error / Transaction / Concurrency ได้ | Workshop: `usp_PlaceOrder` แบบอะตอมมิก |
| **Day 2** | ห่อ logic เป็น Proc / Function / Trigger อย่างมีวินัย | Workshop: API Layer พร้อม Security |

คอร์สนี้เน้น **สร้างของให้ถูก** ไม่ใช่วินิจฉัยระบบช้า  
ถ้าต้องการเจาะ Lock / Plan Cache / DMV เชิงลึก → ไปต่อที่ [sql-server-performance-tuning](https://github.com/DataFabric-Academy/sql-server-performance-tuning)

## เริ่มต้นเร็ว

1. Clone repo (แนะนำ Git ใน **SSMS 22**)
2. Restore **AdventureWorks** บน **SQL Server 2025** (แนะนำ) หรือ 2019+
3. รัน `setup/01-create-lab-objects.sql`
4. ไล่ตาม `docs/day1-agenda.md` → `docs/day2-agenda.md`

| เอกสาร | ใช้เมื่อ |
|--------|---------|
| [`setup/README.md`](setup/README.md) | ติดตั้งเครื่อง |
| [`docs/00-course-outline.md`](docs/00-course-outline.md) | Outline ทั้งคอร์ส |
| [`docs/slide-mapping.md`](docs/slide-mapping.md) | PPT ↔ Lab |
| [`docs/sql-server-2025.md`](docs/sql-server-2025.md) | บริบท engine 2025 |
| [`docs/ssms-git-and-sql-project.md`](docs/ssms-git-and-sql-project.md) | Git + `.sqlproj` |

> **อย่าดับเบิลคลิก `SqlPgSp.sln`** — เปิดใน SSMS 22 ผ่าน `.\scripts\open-labdb-in-ssms.ps1` หรือเปิด `.sqlproj` โดยตรง

## Learning Path

### Day 1 — จาก Script ถึง Transaction ที่ไว้ใจได้

| ลำดับ | Lab / Workshop | Scenario สั้น |
|------:|----------------|---------------|
| 0 | Setup + Intro | เตรียมเครื่องและรู้จัก compat 170 |
| 1 | [`labs/01-language-elements`](labs/01-language-elements) | เขียน batch ให้ตัวแปร/flow ทำงานตามที่คิด |
| 2 | [`labs/02-error-handling`](labs/02-error-handling) | เมื่อพัง ต้องแจ้งและดักได้ ไม่เงียบหาย |
| 3 | [`labs/03-transactions`](labs/03-transactions) | สั่งซื้อหลายตารางต้องสำเร็จหรือล้มทั้งก้อน |
| ★ | [`workshops/integrated-staging-transaction`](workshops/integrated-staging-transaction) | สืบค้น → `#temp` → TRAN อัปเดต (รวม best practice) |
| 4 | [`labs/04-concurrency`](labs/04-concurrency) | คนอ่าน/เขียนพร้อมกันแล้วตัวเลขเพี้ยน |
| ★ | [`workshops/day1-order-processing`](workshops/day1-order-processing) | สร้าง `usp_PlaceOrder` |

### Day 2 — จาก Script เป็น API Layer

| ลำดับ | Lab / Workshop | Scenario สั้น |
|------:|----------------|---------------|
| 5 | [`labs/05-stored-procedures`](labs/05-stored-procedures) | แอปเรียกชื่อ procedure แทนส่ง SQL ยาว |
| 6 | [`labs/06-functions`](labs/06-functions) | ต้องการค่า/ตารางคำนวณโดยไม่ side-effect |
| 7 | [`labs/07-triggers`](labs/07-triggers) | เหตุการณ์ DML ต้องมีปฏิกิริยาอัตโนมัติ |
| ★ | [`workshops/day2-api-layer`](workshops/day2-api-layer) | รวม Proc + TVF + Trigger + GRANT EXECUTE |

## โครงสร้าง Repo

```
docs/           Outline, agenda, slide map, SQL Server 2025
setup/          Lab objects บน AdventureWorks
labs/01–07      Scenario → Demo → Exercise → Solution
workshops/      Capstone ท้ายวัน
src/SqlPgSp.LabDb/   SQL Project (Build/Publish → SqlPgSpLab)
```

แต่ละ lab: `README.md` · `demo.sql` · `exercise.sql` · `solution.sql`

## ความต้องการของระบบ

- Windows 10 / 11 · **SQL Server 2025** (แนะนำ) · **SSMS 22**
- AdventureWorks (compat **170** เมื่อสาธิตฟีเจอร์ 2025)
- (ทางเลือก) .NET SDK สำหรับ `dotnet build`

## Road Map

| ก่อนหน้า | คอร์สนี้ | ถัดไป |
|----------|---------|--------|
| Querying Data with T-SQL | **SQL Programming — Stored Procedure** | Table/Index · [Performance Tuning](https://github.com/DataFabric-Academy/sql-server-performance-tuning) |
