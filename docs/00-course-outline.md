# SQL Server Programming — Stored Procedure (SQL-PG-SP)

หลักสูตร 2 วัน (12 ชม.) สำหรับพัฒนา Database Programming ด้วย T-SQL  
อ้างอิงโครงหลักสูตร: [SQL Server Programming - Stored Procedure | 9Expert](https://www.9experttraining.com/sql-server-programming-stored-procedure-training-course)

## วัตถุประสงค์

1. เข้าใจองค์ประกอบของ T-SQL Script (batch, scope, flow control, error handling)
2. สร้าง Script และ Database Objects ได้เหมาะสม: Stored Procedure, Function, Trigger
3. ประกาศ Transaction และเลือก Isolation Level ได้ถูกต้องตามสถานการณ์

## ผู้เข้าอบรมที่เหมาะสม

- มีพื้นฐาน Query ด้วย T-SQL และต้องการทำงานกับ Transaction / Concurrency
- Developer ที่ต้องการยกระดับโค้ดฝั่งฐานข้อมูล
- ผู้ที่สนใจ Script ที่เกี่ยวกับ Database Performance และ Security Context

## พื้นฐานที่ควรมี

1. ความเข้าใจ Relational Database และการออกแบบเบื้องต้น
2. Query ข้อมูลด้วย T-SQL ได้ดี
3. มีประสบการณ์ภาษาโปรแกรมใดภาษาหนึ่ง

## โครงสร้างเนื้อหา

| ลำดับ | หัวข้อ | Lab / Workshop |
|------:|--------|----------------|
| 0 | Setup สภาพแวดล้อม + Lab Objects | `setup/` |
| 1 | องค์ประกอบภาษา T-SQL และ Scripting | `labs/01-language-elements` |
| 2 | Error Handling | `labs/02-error-handling` |
| 3 | Transaction | `labs/03-transactions` |
| 4 | Concurrency & Isolation Levels | `labs/04-concurrency` |
| — | Workshop Day 1: Order Processing | `workshops/day1-order-processing` |
| 5 | Stored Procedures | `labs/05-stored-procedures` |
| 6 | Functions | `labs/06-functions` |
| 7 | DML Triggers | `labs/07-triggers` |
| — | Workshop Day 2: API Layer | `workshops/day2-api-layer` |

## รูปแบบไฟล์ในแต่ละ Lab

| ไฟล์ | ใช้โดย |
|------|--------|
| `README.md` | วัตถุประสงค์ ลำดับการสอน จุดสังเกต |
| `demo.sql` | Instructor demo |
| `exercise.sql` | แบบฝึกหัดผู้เรียน (มี TODO) |
| `solution.sql` | เฉลย |

## ฐานข้อมูลที่ใช้

- **AdventureWorks** (หรือ AdventureWorks2022) เป็นหลักสำหรับ labs
- Lab objects เสริมบน AdventureWorks: `Production.MiniProducts`, `Sales.Mini*`, `dbo.ErrorLog` (จาก `setup/01-create-lab-objects.sql`)
- **SqlPgSpLab** (ทางเลือก): publish จาก `src/SqlPgSp.LabDb` — ดู [`ssms-git-and-sql-project.md`](ssms-git-and-sql-project.md)

## Source Control & Project

| ไฟล์ | บทบาท |
|------|--------|
| `SqlPgSp.sln` | เปิดใน SSMS 22 / Visual Studio |
| `src/SqlPgSp.LabDb/*.sqlproj` | Schema-as-code ของ Lab DB (Build → dacpac → Publish) |
| `labs/`, `workshops/` | สคริปต์ pedagogy — **ไม่อยู่ใน sqlproj** |
