# Lab 02 — Error Handling

**PPT:** โมดูล 2 (ส่วนท้าย) · สไลด์ **36–45** · ในสไลด์อยู่ใน “องค์ประกอบ T-SQL” — แยก lab เพื่อจัดเวลา

## Scenario

สคริปต์ตัดสต็อกพังกลางคัน แต่แอปเห็นแค่ “Query failed” โดยไม่มีรหัส/ข้อความที่ใช้แก้ได้  
และบางที error เงียบหายเพราะ severity ต่ำหรือไม่ได้ดักใน `TRY/CATCH`  
ทีมต้องการแพทเทิร์น **แจ้ง → ดัก → บันทึก → ส่งต่อ** ก่อนห่อเป็น Procedure

## Skill Progression

| ระดับ | ทักษะที่ควรได้ |
|------:|----------------|
| 1 | อธิบาย Severity / Message ID / ความต่าง `RAISERROR` vs `THROW` |
| 2 | เขียน `TRY/CATCH` + `ERROR_*` และ custom message (`sp_addmessage`) ได้ |
| 3 | Rethrow + บันทึก `dbo.ErrorLog` ได้อย่างปลอดภัย |

## เวลา / Prerequisites

**45–60 นาที** · Lab 01 · มี `dbo.ErrorLog` จาก setup · (custom message อาจต้องสิทธิ์ `master`)

## Steps

| ลำดับ | ไฟล์ | ทำอะไร |
|------:|------|--------|
| 1 | `demo.sql` | Instructor — รวมโน้ต Managed Code **6522** และทางเลือก REGEXP แทน CLR |
| 2 | `exercise.sql` | ผู้เรียน |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. `THROW` ใน `CATCH` โดยไม่มีพารามิเตอร์ = rethrow (แนะนำ)  
2. Severity ≤ 10 มักไม่เข้า `CATCH`  
3. บาง compile / connection-level error ดักไม่ได้  
4. บันทึก `ERROR_*` **ก่อน** `THROW` อีกครั้ง

## Takeaways

- Error ที่ดี = ผู้เรียกแก้ต่อได้ (รหัส + ข้อความชัด)  
- แพทเทิร์นนี้จะถูกใช้ซ้ำใน Lab 03 / 05 และ Workshop
