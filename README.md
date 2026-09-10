# SQL Server Programming — Stored Procedure

หลักสูตร **2 วัน (12 ชม.)** สำหรับ Database Programming ด้วย T-SQL: Scripting, Transaction, Concurrency, Stored Procedure, Function และ Trigger

อ้างอิงโครง: [SQL Server Programming - Stored Procedure (9Expert)](https://www.9experttraining.com/sql-server-programming-stored-procedure-training-course)

## เริ่มต้นเร็ว

1. Clone repo (แนะนำเปิดด้วย **Git ใน SSMS 22**)
2. ติดตั้ง / กู้ **AdventureWorks** (หรือ AdventureWorks2022)
3. รัน `setup/01-create-lab-objects.sql`
4. ดูแผนอบรมที่ `docs/day1-agenda.md` และ `docs/day2-agenda.md`
5. ไล่ Lab ใน `labs/` แล้วจบแต่ละวันด้วย `workshops/`

รายละเอียดสภาพแวดล้อม: [`setup/README.md`](setup/README.md)  
Outline เต็ม: [`docs/00-course-outline.md`](docs/00-course-outline.md)  
Git + SQL Project: [`docs/ssms-git-and-sql-project.md`](docs/ssms-git-and-sql-project.md)

> **อย่าดับเบิลคลิก `SqlPgSp.sln`** — Windows จะเปิด Visual Studio แล้วขึ้น *Unsupported*  
> เปิดใน **SSMS 22** ด้วย `.\scripts\open-labdb-in-ssms.ps1` หรือ File → Open → `src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj`

## โครงสร้าง Repo

```
SqlPgSp.sln                 Solution (เปิดใน SSMS 22 เท่านั้น — อย่าดับเบิลคลิก)
src/SqlPgSp.LabDb/          SQL Project (Microsoft.Build.Sql)
scripts/                    เปิดโปรเจกต์ด้วย SSMS
docs/                       Outline + Agenda + คู่มือ Git/Project
setup/                      สร้าง Lab objects บน AdventureWorks
labs/                       01–07 ตามหัวข้อหลักสูตร (สคริปต์เรียน)
workshops/                  Case study เข้มข้นท้ายวัน
```

แต่ละ lab มี `README.md`, `demo.sql`, `exercise.sql`, `solution.sql`

## ความต้องการของระบบ

- Windows 10 / 11
- SQL Server (Developer / Express / บน Lab VM) + **SSMS 22** (แนะนำ เปิด Database DevOps workload)
- AdventureWorks sample database
- (ทางเลือก) .NET SDK สำหรับ `dotnet build` SQL project
- Internet (ดาวน์โหลด sample / เอกสาร)

## Road Map ที่เกี่ยวข้อง

| ก่อนหน้า | คอร์สนี้ | ถัดไป |
|----------|---------|--------|
| Querying Data with T-SQL | **SQL Programming — Stored Procedure** | Table Structure & Index / Database Development |
