# Lab 05 — Stored Procedures

**PPT:** โมดูล 5 · สไลด์ **61–73** · Sniffing 71 · EXECUTE AS 72 · ENCRYPTION 73

## Scenario

แอปส่ง SQL ยาวหลายรอบต่อหนึ่งออเดอร์ — ยากต่อการควบคุมสิทธิ์และแผนการรัน  
ทีมต้องการให้แอปเรียกแค่ชื่อ เช่น `Sales.usp_PlaceOrder` พร้อม parameter, error log และแนวทางลดปัญหา plan ผิดชุด (Parameter Sniffing)

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบายประโยชน์ SP และคำสั่งที่ใส่ใน SP ไม่ได้ (สไลด์ 64) |
| 2 | สร้าง SP ด้วย INPUT / OUTPUT / RETURN + `SET NOCOUNT ON` + ErrorLog |
| 3 | เลือก mitigation sniffing (`OPTIMIZE FOR` / local var / `RECOMPILE`) และอธิบาย PSP/OPPO บน SQL Server 2025 |

> Plan cache / sniffing เชิงลึก → [PT Module 08 Plan Caching](https://github.com/DataFabric-Academy/sql-server-performance-tuning/tree/main/Module_08_Plan_Caching)

## เวลา / Prerequisites

**90–100 นาที** · Day 1 เสร็จ (โดยเฉพาะ Lab 02–03) · Mini* + ErrorLog

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | Benefits → Params → Security → Sniffing → Nested → (2025 note) |
| 2 | `exercise.sql` | ผู้เรียน |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

| หัวข้อ | จุดสังเกต |
|--------|-----------|
| Naming | ห้ามขึ้นต้น `sp_` · ใช้ two-part name |
| OUTPUT vs RETURN | OUTPUT ส่งค่าธุรกิจ; RETURN = int status |
| ENCRYPTION | ปกป้อง definition ไม่ใช่ security แข็งแรง |
| EXECUTE AS | เปลี่ยน security context ภายใน proc |
| 2025 / compat 170 | PSP สำหรับ DML + OPPO ช่วย sniffing ฝั่ง engine — mitigation แบบ manual ยังสำคัญ |

รายละเอียด: [`sql-server-2025.md`](../../docs/sql-server-2025.md)

## Takeaways

- SP คือหน่วย API ของฐานข้อมูล — หนึ่งงานต่อหนึ่ง procedure  
- ความปลอดภัยที่ดีเริ่มจาก `GRANT EXECUTE` ไม่เปิดตารางตรง ๆ
