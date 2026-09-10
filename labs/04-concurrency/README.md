# Lab 04 — Concurrency & Isolation Levels

## วัตถุประสงค์

เข้าใจปัญหา concurrency และเลือก isolation level / เทคนิคที่เหมาะสม:

- Dirty read / Non-repeatable read / Phantom read
- Pessimistic isolation: `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`
- Optimistic: `SNAPSHOT` (+ พูดถึง RCSI ระดับ database)
- ฝึกเปิด **2 sessions** ใน SSMS แล้วรันคู่กันตาม step

## ระยะเวลาประมาณ

**75–90 นาที**

## Prerequisites

- Lab 03 (transaction พื้นฐาน)
- AdventureWorks; ตาราง `Person.PersonPhone`, `Production.ProductCategory`
- สำหรับ SNAPSHOT: สิทธิ์ `ALTER DATABASE … SET ALLOW_SNAPSHOT_ISOLATION ON`

## ลำดับการรันไฟล์

| ลำดับ | ไฟล์ | ผู้ใช้ |
|------:|------|--------|
| 1 | `demo.sql` | Overview + ตารางสรุปปัญหา vs isolation |
| 2 | `sessions/01-dirty-read-s1.sql` + `…-s2.sql` | คู่ Session |
| 3 | `sessions/02-read-committed-s1.sql` + `…-s2.sql` | คู่ Session |
| 4 | `sessions/03-nonrepeatable-s1.sql` + `…-s2.sql` | คู่ Session |
| 5 | `sessions/04-phantom-s1.sql` + `…-s2.sql` | คู่ Session |
| 6 | `sessions/05-snapshot-s1.sql` + `…-s2.sql` | คู่ Session (เปิด SNAPSHOT ก่อน) |
| 7 | `exercise.sql` → `solution.sql` | ผู้เรียน |

### วิธีรันคู่ Session

1. เปิดหน้าต่าง Query **2 อัน** ใน SSMS (Session 1 / Session 2)
2. ทั้งคู่ `USE AdventureWorks;`
3. ทำตามหมายเหตุ `-- Step N` สลับไฟล์ s1 ↔ s2
4. จบทุก demo ด้วย `ROLLBACK` / cleanup ตามสคริปต์ — **อย่า commit ค่าทดลองทิ้ง**

## จุดที่ต้องสังเกต

| ปัญหา | อ่านข้อมูลที่… | กันด้วย |
|--------|----------------|---------|
| Dirty read | ยังไม่ commit ของ session อื่น | ≥ READ COMMITTED (default) |
| Non-repeatable | แถวเดิมถูก update/commit ระหว่างอ่านซ้ำ | REPEATABLE READ / SNAPSHOT / SERIALIZABLE |
| Phantom | มีแถวใหม่เข้าช่วง predicate | SERIALIZABLE / SNAPSHOT |

1. **READ UNCOMMITTED = dirty read ได้** (และไม่รอ shared lock แบบปกติ)
2. **READ COMMITTED** กัน dirty แต่ยังเจอ non-repeatable / phantom
3. **REPEATABLE READ** กันแถวที่อ่านแล้วถูกเปลี่ยน แต่ยังมี phantom
4. **SERIALIZABLE** ใช้ range lock — concurrency ต่ำลง ระวัง blocking/deadlock
5. **SNAPSHOT** อ่านเวอร์ชันจาก tempdb (row versioning) — ไม่ dirty/non-repeatable/phantom แบบ write skew ยังต้องออกแบบเพิ่ม
6. **RCSI** (`READ_COMMITTED_SNAPSHOT ON`) ทำให้ statement-level READ COMMITTED ใช้ versioning — พูดถึงใน demo ไม่บังคับเปิดใน lab

## Key Takeaways

- Default `READ COMMITTED` เหมาะงานทั่วไป แต่ไม่พอถ้า logic อ่านซ้ำแล้วตัดสินใจ
- งานสต็อก/ออเดอร์ที่แข่งกัน → มักใช้ transaction สั้น + locking ที่ชัด หรือ optimistic + retry
- ทดสอบ concurrency ต้องมีอย่างน้อย 2 sessions เสมอ — อ่านทฤษฎีอย่างเดียวไม่พอ
