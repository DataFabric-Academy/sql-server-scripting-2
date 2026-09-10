# Lab 06 — Functions (Scalar / TVF)

## วัตถุประสงค์

1. แยกแยะ Scalar UDF, Inline TVF และ Multi-statement TVF ได้
2. เลือกชนิด Function ให้เหมาะกับงาน และอธิบายผลกระทบด้าน performance
3. เปรียบเทียบ Scalar / mTVF กับทางเลือก (Inline TVF, JOIN, APPLY, computed column)
4. เข้าใจข้อจำกัดด้าน side-effect และ security context ของ Function โดยสังเขป

## ระยะเวลาประมาณ

**70–80 นาที**

## Prerequisites

- Lab 05 เสร็จแล้ว (รู้ CREATE MODULE / parameters)
- `setup/01-create-lab-objects.sql` รันแล้ว
- Database: `AdventureWorks` หรือ `AdventureWorks2022`

## ลำดับการรันไฟล์

1. `demo.sql` — เทียบ Scalar vs Inline TVF vs mTVF + STATISTICS TIME/IO
2. `exercise.sql`
3. `solution.sql`

## เมื่อไหร่ใช้ชนิดไหน

| ชนิด | ใช้เมื่อ | ข้อควรระวัง |
|------|----------|-------------|
| **Scalar UDF** | คำนวณค่าเดียวต่อแถว / ค่าคงที่ logic เล็ก ๆ | ก่อน SQL Server 2019 มักเรียกแบบ row-by-row; แม้มี inlining ก็ยังต้องระวัง |
| **Inline TVF** | คืนผลเป็นชุดแถว และต้องการให้ optimizer **expand** เข้า query | **แนะนำเป็นค่าเริ่มต้น** สำหรับ table-valued API |
| **Multi-statement TVF** | ต้องใช้หลายขั้นตอน / ตัวแปร / logic ที่เขียนเป็น single RETURN query ไม่ได้ | Table variable ภายใน → สถิติไม่ดี, มักช้ากว่า inline |

## จุดที่ต้องสังเกต

- เปิด `SET STATISTICS TIME ON` / `IO ON` หรือดู Estimated Plan: Inline TVF มักถูก embed; mTVF เป็น Table Valued Function operator แยก
- Function **ห้าม** เปลี่ยนข้อมูลถาวร (no INSERT/UPDATE/DELETE ตารางจริง) — ไม่ใช่ที่สำหรับ business write API
- Security: ownership chaining คล้าย procedure; `EXECUTE AS` ใช้ได้แต่ไม่ใช่จุดหลักของ lab นี้

## Key Takeaways

- Prefer **Inline TVF** สำหรับ “query API” ที่คืนตาราง
- Scalar / mTVF ใช้ได้ แต่วัด performance ก่อนโปรโมตขึ้น production
- หลายครั้ง JOIN / APPLY / computed column ชัดและเร็วกว่า UDF ที่ซับซ้อน
