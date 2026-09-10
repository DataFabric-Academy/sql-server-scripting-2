# Workshop Day 2 — API Layer

## สถานการณ์ (Scenario)

สร้าง **API layer ขนาดเล็กใน SQL Server** สำหรับแอปขายของ โดยรวม Stored Procedure, Inline TVF และ Trigger:

| Object | หน้าที่ |
|--------|---------|
| `Sales.usp_CreateCustomer` | สร้างลูกค้าใหม่ คืน `CustID` |
| `Sales.usp_PlaceOrder` | วางออเดอร์อะตอมมิก (reuse/improve จาก Day 1) |
| `Sales.ufn_GetCustomerOrderSummary` | Inline TVF สรุปออเดอร์ต่อลูกค้า |
| Trigger audit **หรือ** soft-delete `INSTEAD OF DELETE` บน `MiniOrders` | บังคับนโยบายที่ชั้นข้อมูล |
| `dbo.usp_LogError` + `dbo.ErrorLog` | บันทึก error จาก CATCH |

เป้าหมายคือให้แอปเรียกแค่ module เหล่านี้ — ไม่เขียน DML ตรง ๆ บนตาราง Mini*

## Timebox

| ช่วง | เวลา |
|------|------|
| อ่านโจทย์ / ออกแบบ | 10 นาที |
| Implement จาก `starter.sql` | 50–60 นาที |
| Security notes + เทียบ solution | 15 นาที |
| **รวม** | **~75–85 นาที** |

## Acceptance Criteria

1. **`usp_CreateCustomer`**
   - รับข้อมูลลูกค้าจำเป็น (CompanyName, ContactName, ContactTitle, Address, City, Country, Phone) + optional Region/PostalCode
   - คืน `@CustID OUTPUT`
   - Validate ชื่อไม่ว่าง; ใช้ TRY/CATCH + `usp_LogError`

2. **`usp_PlaceOrder`**
   - อะตอมมิกเหมือน Workshop Day 1
   - รองรับอย่างน้อยหนึ่งบรรทัดสินค้า (หรือ TVP ถ้าทำโบนัส)
   - Error codes อ่านรู้เรื่อง + เขียน ErrorLog

3. **`ufn_GetCustomerOrderSummary(@CustID)`** — **Inline TVF**
   - คอลัมน์อย่างน้อย: `OrderID`, `OrderDate`, `Status`, `LineCount`, `MerchandiseTotal`, `Freight`
   - `MerchandiseTotal` = Σ (UnitPrice * Quantity * (1 - Discount))

4. **Trigger (เลือกอย่างน้อย 1)**
   - `Sales.trg_MiniOrders_Audit` — AFTER INSERT/UPDATE บันทึกประวัติ **หรือ**
   - `INSTEAD OF DELETE` บน `MiniOrders` เปลี่ยน `Status = 'Cancelled'` (soft-delete)

5. **Security demo notes (ใน README นี้ + คอมเมนต์ใน solution)**
   - สร้าง user ไร้ login เช่น `ApiCaller`
   - `GRANT EXECUTE` บน procedures / `GRANT SELECT` บน TVF
   - `DENY` สิทธิ์ตารางตรง ๆ
   - อธิบาย ownership chaining และทางเลือก `EXECUTE AS OWNER`

## Security — GRANT EXECUTE demo (ทำในคลาส)

```sql
CREATE USER ApiCaller WITHOUT LOGIN;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniCustomers TO ApiCaller;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniOrders TO ApiCaller;
DENY SELECT, INSERT, UPDATE, DELETE ON Sales.MiniOrderDetails TO ApiCaller;
DENY SELECT, UPDATE ON Production.MiniProducts TO ApiCaller;

GRANT EXECUTE ON Sales.usp_CreateCustomer TO ApiCaller;
GRANT EXECUTE ON Sales.usp_PlaceOrder TO ApiCaller;
GRANT SELECT ON Sales.ufn_GetCustomerOrderSummary TO ApiCaller;

EXECUTE AS USER = N'ApiCaller';
-- เรียก proc/TVF ได้ แต่ SELECT ตารางตรง ๆ ไม่ได้
REVERT;
```

ถ้า ownership chaining ไม่ครอบคลุม cross-schema ตามที่คาด ให้พิจารณา `WITH EXECUTE AS OWNER` บน procedure

## Hints

1. ทำ `usp_LogError` ให้พร้อมก่อน
2. Implement `usp_CreateCustomer` ก่อน แล้วค่อย refine `usp_PlaceOrder`
3. Inline TVF = `RETURNS TABLE AS RETURN ( SELECT ... )` เท่านั้น
4. Soft-delete: ระวัง FK จาก `MiniOrderDetails` — soft-delete ไม่ลบหัวออเดอร์จริง จึงไม่ชน FK
5. ทดสอบทั้ง happy path และ stock/customer failure

## ลำดับไฟล์

1. `starter.sql`
2. เทียบ `solution.sql`

## Prerequisites

- Labs 05–07
- Workshop Day 1 (อย่างน้อยเข้าใจ `usp_PlaceOrder`)
- `setup/01-create-lab-objects.sql`
