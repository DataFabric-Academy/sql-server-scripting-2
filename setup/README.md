# Setup — สภาพแวดล้อม Lab

## วัตถุประสงค์

เตรียมเครื่องสำหรับหลักสูตร SQL Server Programming (Day 1–2) ให้พร้อมรัน lab ทุกชุดบน AdventureWorks

## Prerequisites

| รายการ | รายละเอียด |
|--------|------------|
| SQL Server | 2019 ขึ้นไป (แนะนำ 2022) — Developer / Express ก็ได้ |
| SSMS | [Download SSMS](https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms) ล่าสุด |
| AdventureWorks | ฐานข้อมูลตัวอย่างจาก Microsoft |

## 1) ติดตั้ง AdventureWorks

1. ดาวน์โหลด backup จาก  
   [sql-server-samples / adventureworks](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks)  
   (เลือก `AdventureWorks2022.bak` หรือรุ่นที่ตรงกับ SQL Server ของคุณ)
2. ใน SSMS: คลิกขวา **Databases** → **Restore Database…**
3. เลือก **Device** → ชี้ไปที่ไฟล์ `.bak` → Restore
4. ตรวจว่า database ปรากฏใน Object Explorer (ชื่ออาจเป็น `AdventureWorks` หรือ `AdventureWorks2022`)

> หากชื่อ DB เป็น `AdventureWorks2022` ให้แก้บรรทัด `USE AdventureWorks;` ในสคริปต์ lab ให้ตรงกัน หรือสร้าง synonym/alias ตามสะดวกของทีม

## 2) ติดตั้ง / เปิด SSMS

1. เปิด SSMS แล้วเชื่อมต่อ instance ของคุณ (เช่น `(local)` หรือ `localhost`)
2. ตั้ง **Query → SQLCMD Mode** ไม่จำเป็นสำหรับ lab ชุดนี้
3. แนะนำ: เปิด **Include Actual Execution Plan** เมื่อทำ lab language elements (table variable vs temp table)

## 3) รัน Setup Script

1. เปิดไฟล์ `setup/01-create-lab-objects.sql`
2. ตรวจชื่อ database ใน `USE …` ให้ตรงกับเครื่องคุณ
3. กด **Execute** (F5)
4. ตรวจ Messages และ Result sets:
   - มีแถว ProductID `854`, `859`, `860` และ Quantity > 0
   - มีลูกค้าใน `Sales.MiniCustomers` อย่างน้อย 3 ราย
   - มีตาราง `dbo.ErrorLog`

## 4) ตรวจว่าพร้อมเรียน

รันชุดนี้แล้วควรได้ผลลัพธ์ (ไม่ error):

```sql
USE AdventureWorks;  -- หรือ AdventureWorks2022
GO
SELECT COUNT(*) AS MiniProducts FROM Production.MiniProducts;
SELECT COUNT(*) AS MiniCustomers FROM Sales.MiniCustomers;
SELECT OBJECT_ID(N'dbo.ErrorLog') AS ErrorLogObjectId;
```

## ลำดับการใช้ในคอร์ส

1. `setup/01-create-lab-objects.sql` ← **รันครั้งเดียวก่อน Day 1**
2. `labs/01-language-elements` → `02` → `03` → `04`
3. `workshops/day1-order-processing`
4. Day 2 labs / workshop

## ทางเลือก: SQL Project (SqlPgSpLab)

นอกจากสคริปต์บน AdventureWorks ยังมี **Microsoft.Build.Sql project** ที่ `src/SqlPgSp.LabDb/` สำหรับ Build/Publish ไปยัง database ชื่อ `SqlPgSpLab` (sandbox แยก)

- ใช้สอน Git + Database DevOps ใน SSMS 22
- **ไม่แทนที่** setup บน AdventureWorks สำหรับ lab concurrency ที่พึ่ง `Person.PersonPhone` ฯลฯ
- รายละเอียด: [`docs/ssms-git-and-sql-project.md`](../docs/ssms-git-and-sql-project.md)

## จุดที่ต้องระวัง

- สคริปต์ setup **DROP** ตาราง Mini* แล้วสร้างใหม่ — อย่ารันซ้ำกลางวันโดยไม่แจ้งผู้เรียนถ้ามีข้อมูลทดลองค้างอยู่
- Lab concurrency ใช้ `Person.PersonPhone` และ `Production.ProductCategory` ของ AdventureWorks โดยตรง — อย่า commit ค่า demo ทิ้งไว้ (session ไฟล์จะ ROLLBACK)
- หากสิทธิ์ไม่พอ: ขอ `db_ddladmin` หรือสิทธิ์เทียบเท่าบน AdventureWorks สำหรับช่วงอบรม
