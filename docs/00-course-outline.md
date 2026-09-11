# SQL Server Programming — Stored Procedure (SQL-PG-SP)

หลักสูตร 2 วัน (12 ชม.) ตามสไลด์ **9Expert Training-SQL-PG-SP Version 5** (อ.ภัคพงศ์)  
เว็บอ้างอิง: [SQL Server Programming - Stored Procedure | 9Expert](https://www.9experttraining.com/sql-server-programming-stored-procedure-training-course)

แผนสไลด์ ↔ lab: [`slide-mapping.md`](slide-mapping.md)  
บริบท SQL Server **2025**: [`sql-server-2025.md`](sql-server-2025.md)

## วัตถุประสงค์ (ตามหลักสูตร)

1. เข้าใจองค์ประกอบต่าง ๆ ในการสร้าง Script
2. สร้าง Script และนำไปสร้าง Objects ชนิดต่าง ๆ ได้อย่างเหมาะสม
3. ประกาศ Transaction และเลือกใช้ Isolation Level ได้อย่างเหมาะสม

## โครงสร้างตาม TOC สไลด์ (หน้า 11 / 107)

| โมดูล PPT | สไลด์ | ใน repo |
|----------:|------:|---------|
| 1. สิ่งที่ควรทราบก่อนใช้งาน Microsoft SQL Server | 13–18 | [`module-01-sql-server-intro.md`](module-01-sql-server-intro.md) |
| 2. องค์ประกอบต่าง ๆ ของภาษา T-SQL *(รวม Error Handling)* | 20–45 | `labs/01-language-elements` + `labs/02-error-handling` |
| 3. การประกาศ Transaction | 47–52 | `labs/03-transactions` |
| 4. การควบคุมภาวะใช้งานพร้อมกัน | 54–59 | `labs/04-concurrency` |
| 5. ออกแบบและสร้าง Stored Procedures | 61–73 | `labs/05-stored-procedures` |
| 6. ออกแบบและสร้าง Functions | 75–89 | `labs/06-functions` |
| 7. ออกแบบและสร้าง Triggers | 91–105 | `labs/07-triggers` |

> **หมายเหตุ pedagogy:** PPT รวม Error Handling ในโมดูล 2 แต่ repo **แยก Lab 02** เพื่อจัดเวลาและ workshop — เนื้อหาเทียบสไลด์ 36–45

## แบบฝึกหัด vs สไลด์ Note

| ของใน PPT | ความหมาย | ของใน repo |
|-----------|----------|------------|
| สไลด์ **Note** (19, 46, 53, …) | หน้าจดว่าง | ไม่ใช่โจทย์ |
| ตัวอย่างโค้ดบนสไลด์เนื้อหา | Instructor demo | `labs/*/demo.sql` |
| — | แบบฝึกผู้เรียน | `labs/*/exercise.sql` + `solution.sql` |
| — | Capstone / Pattern | `workshops/integrated-staging-transaction`, `day1-order-processing`, `day2-api-layer` |

## ผู้เข้าอบรม / พื้นฐาน

- มีพื้นฐาน Query ด้วย T-SQL และต้องการทำงานกับ Transaction / Concurrency  
- Developer ที่ต้องการยกระดับโค้ดฝั่งฐานข้อมูล  
- เข้าใจ Relational Database เบื้องต้น และ Query ได้ดี

## รูปแบบไฟล์ในแต่ละ Lab

| ไฟล์ | ใช้โดย |
|------|--------|
| `README.md` | วัตถุประสงค์, **เลขสไลด์**, จุดสังเกต |
| `demo.sql` | Instructor — สอดคล้องตัวอย่างบนสไลด์ |
| `exercise.sql` | ผู้เรียน (TODO) |
| `solution.sql` | เฉลย |

## ฐานข้อมูล

- **AdventureWorks** (+ objects จาก `setup/01-create-lab-objects.sql`: Mini*, ErrorLog)
- ทางเลือก: publish `src/SqlPgSp.LabDb` → `SqlPgSpLab` — [`ssms-git-and-sql-project.md`](ssms-git-and-sql-project.md)
