# Lab 02 — Error Handling

## วัตถุประสงค์

จัดการข้อผิดพลาดใน T-SQL อย่างเป็นระบบ:

- เปรียบเทียบ `RAISERROR` กับ `THROW`
- Custom message ผ่าน `sp_addmessage` / `sys.messages`
- `FORMATMESSAGE`
- `TRY/CATCH` และฟังก์ชัน `ERROR_*`
- ข้อผิดพลาดที่ catch ไม่ได้
- แพทเทิร์น rethrow + บันทึกลง `dbo.ErrorLog`

## ระยะเวลาประมาณ

**45–60 นาที**

## Prerequisites

- Lab 01 เสร็จแล้ว (เข้าใจ batch / variable)
- มีตาราง `dbo.ErrorLog` จาก `setup/01-create-lab-objects.sql`
- สิทธิ์รัน `sp_addmessage` บน `master` (หรือ instructor รันส่วน custom message ให้)

## ลำดับการรันไฟล์

| ลำดับ | ไฟล์ | ผู้ใช้ |
|------:|------|--------|
| 1 | `demo.sql` | Instructor — รันทีละ section; ส่วน `sp_addmessage` อาจต้องสิทธิ์สูง |
| 2 | `exercise.sql` | ผู้เรียน |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. **`THROW` ไม่มีพารามิเตอร์** ใน `CATCH` = rethrow ของ error เดิม (แนะนำ)
2. **`RAISERROR` severity 11–19** เข้า `CATCH` ได้; severity ≤10 เป็น informational
3. **`THROW` ต้องการ message_id ≥ 50000** เมื่อระบุเอง; และ statement ก่อนหน้าต้องจบด้วย `;`
4. **Compilation / batch-aborting errors บางชนิดไม่เข้า CATCH** (เช่น syntax error ทั้ง batch, บาง connection-level)
5. บันทึก `ERROR_*` ลง `ErrorLog` **ก่อน** `THROW` อีกครั้ง — หลังออกจาก CATCH ค่า `ERROR_*` หาย

## Key Takeaways

- Production code ควรใช้ `TRY/CATCH` + บันทึก log + `THROW;` (rethrow)
- แยก business error (custom 50000+) จาก system error
- `XACT_ABORT` จะคุยต่อใน Lab 03 — error handling กับ transaction ต้องออกแบบคู่กัน
