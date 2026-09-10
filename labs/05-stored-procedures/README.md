# Lab 05 — Stored Procedures

## วัตถุประสงค์

1. อธิบายประโยชน์ของ Stored Procedure เทียบกับ ad-hoc SQL ได้
2. สร้าง Procedure พร้อม Input / OUTPUT / RETURN และเรียกใช้ถูกต้อง
3. จัดการ Error ใน Procedure ด้วย TRY/CATCH + `usp_LogError` → `dbo.ErrorLog`
4. ใช้ recommendation ที่สำคัญ: `SET NOCOUNT ON`, หลีกเลี่ยง `SELECT *`, `WITH ENCRYPTION`, `EXECUTE AS`
5. อธิบาย Parameter Sniffing และ mitigation patterns ได้
6. เรียก Nested Procedure และรู้จัก TVP แบบสั้น ๆ

## ระยะเวลาประมาณ

**90–100 นาที** (Demo ~45 นาที + Exercise ~40 นาที + Review ~10 นาที)

## Prerequisites

- รัน `setup/01-create-lab-objects.sql` แล้ว
- เข้าใจ TRY/CATCH และ Transaction จาก Day 1
- Database: `AdventureWorks` หรือ `AdventureWorks2022`

## ลำดับการรันไฟล์

1. Instructor: `demo.sql` (ทีละ section ตามหัวข้อ)
2. ผู้เรียน: `exercise.sql`
3. ตรวจคำตอบ: `solution.sql`

## จุดที่ต้องสังเกต

| หัวข้อ | จุดสังเกต |
|--------|-----------|
| Benefits | Encapsulation, security (GRANT EXECUTE), plan reuse, network round-trips |
| Parameters | INPUT ปกติ / `OUTPUT` ต้องส่งตัวแปรกลับ / `RETURN` เป็น int status เท่านั้น |
| Error handling | เรียก `usp_LogError` ใน CATCH ก่อน THROW — ดูแถวใน `dbo.ErrorLog` |
| SET NOCOUNT ON | ลด DONE_IN_PROC messages ที่ทำให้ client บางตัวสับสน |
| ENCRYPTION | `sp_helptext` / definition ใน catalog ดูไม่ได้ — ใช้เพื่อปกป้อง IP ไม่ใช่ security ที่แข็งแรง |
| EXECUTE AS | เปลี่ยน security context ของ caller ภายใน procedure |
| Parameter Sniffing | Plan ที่ compile ด้วย parameter แรกอาจไม่เหมาะกับค่าถัดไป |
| Nested procs | `@@NESTLEVEL` สูงสุด 32 |
| TVP | ส่งชุดข้อมูลเข้า procedure ได้โดยไม่ต้อง string-split |

## Key Takeaways

- Procedure คือ API layer ของฐานข้อมูล — ออกแบบ parameter และ error contract ให้ชัด
- ใช้ OUTPUT สำหรับค่าผลลัพธ์, RETURN สำหรับ status code
- Parameter Sniffing ไม่ใช่ bug แต่เป็นพฤติกรรมของ plan cache — เลือก mitigation ตาม workload
- `WITH ENCRYPTION` ไม่แทนที่สิทธิ์และการควบคุมการเข้าถึง
- Nested procedure ช่วยแยกความรับผิดชอบ แต่ต้องออกแบบ error propagation ให้ดี
