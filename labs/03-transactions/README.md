# Lab 03 — Transactions

## วัตถุประสงค์

ออกแบบและควบคุม transaction ให้ข้อมูลสอดคล้องกัน (ACID):

- ความหมายของ transaction; Implicit / Explicit / Autocommit
- `BEGIN` / `COMMIT` / `ROLLBACK` และ `@@TRANCOUNT`
- ผลของ error เมื่อไม่เปิด `XACT_ABORT`
- `SET XACT_ABORT ON`
- แพทเทิร์น `TRY/CATCH` + `XACT_STATE()`
- ใช้ตาราง Mini* จำลอง insert ออเดอร์ที่อาจชน `CHECK (Quantity >= 0)`

## ระยะเวลาประมาณ

**60–75 นาที**

## Prerequisites

- Lab 02 (TRY/CATCH, THROW)
- มี `Production.MiniProducts`, `Sales.MiniCustomers`, `Sales.MiniOrders`, `Sales.MiniOrderDetails`
- แนะนำรีเซ็ตสต็อก 854/859/860 ถ้าทดลองจนติดลบเกือบหมด:

```sql
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID WHEN 854 THEN 100 WHEN 859 THEN 50 WHEN 860 THEN 50 END
WHERE ProductID IN (854,859,860);
```

## ลำดับการรันไฟล์

| ลำดับ | ไฟล์ | ผู้ใช้ |
|------:|------|--------|
| 1 | `demo.sql` | Instructor — รันทีละ section; สังเกต `@@TRANCOUNT` และสต็อก |
| 2 | `exercise.sql` | ผู้เรียน |
| 3 | `solution.sql` | เฉลย |

## จุดที่ต้องสังเกต

1. **Autocommit** คือ default — แต่ละ statement เป็น transaction ย่อย (สำเร็จ commit / ล้ม rollback statement นั้น)
2. **`@@TRANCOUNT`** เพิ่มทุก `BEGIN TRAN`; `COMMIT` ลดทีละ 1; `ROLLBACK` เคลียร์ทั้งหมดกลับ 0
3. **Nested `BEGIN TRAN` ไม่ได้สร้าง nested true transaction** — เป็นแค่การนับ; rollback ในชั้นในจะ rollback ทั้งก้อน
4. **ไม่มี `XACT_ABORT`**: runtime error บางชนิด rollback แค่ statement แต่ transaction ยังเปิด → batch ต่ออาจเจอ “transaction doomed” หรือข้อมูลค้างครึ่ง ๆ
5. **`XACT_STATE()`**: `1` = committable, `0` = ไม่มี tran, `-1` = uncommittable → ต้อง `ROLLBACK`

## Key Takeaways

- งานหลายตารางที่ต้อง atomic → Explicit transaction + `TRY/CATCH` + `XACT_ABORT ON`
- ตรวจ `XACT_STATE()` ก่อน `COMMIT`/`ROLLBACK` ใน CATCH
- ใช้ Mini* + CHECK เป็นโมเดล “สต็อกติดลบไม่ได้” ก่อนขึ้น production procedure จริง
