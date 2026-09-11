# Workshop Day 2 — API Layer

**Capstone หลัง Lab 05–07** · PPT โมดูล 5–7 (สไลด์ 61–105) · ส่วนขยายของ repo (ไม่ได้อยู่บนสไลด์ Note)

## Scenario

แอปขายของต้องคุยกับ SQL Server ผ่าน **API layer** เท่านั้น — ห้าม `SELECT`/`INSERT` ตาราง Mini* ตรงจากแอป  
คุณต้องส่งมอบชุด object ที่แอปเรียกได้ พร้อม audit/soft-delete และแนว `GRANT EXECUTE`

| Object | หน้าที่ |
|--------|---------|
| `Sales.usp_CreateCustomer` | สร้างลูกค้า คืน `CustID` |
| `Sales.usp_PlaceOrder` | ออเดอร์อะตอมมิก (ต่อจาก Day 1) |
| `Sales.ufn_GetCustomerOrderSummary` | Inline TVF สรุปออเดอร์ |
| Trigger audit และ/หรือ soft-delete | นโยบายที่ชั้นข้อมูล |
| `dbo.usp_LogError` | บันทึก error |

## Skill Progression

| ระดับ | ทักษะที่พิสูจน์ใน workshop นี้ |
|------:|--------------------------------|
| 1 | ประกอบ Proc + Inline TVF + Trigger ให้ทำงานร่วมกัน |
| 2 | Error handling + transaction สม่ำเสมอทั้ง API |
| 3 | ออกแบบสิทธิ์ `GRANT EXECUTE` / `DENY` ตาราง (ownership chaining / `EXECUTE AS`) |

## Timebox

| ช่วง | เวลา |
|------|------|
| อ่านโจทย์ / ออกแบบ | 10 นาที |
| Implement จาก `starter.sql` | 50–60 นาที |
| Security notes + solution | 15 นาที |
| **รวม** | **~75–85 นาที** |

## Acceptance Criteria

1. **`usp_CreateCustomer`** — validate ช่องจำเป็น, `@CustID OUTPUT`, TRY/CATCH + ErrorLog  
2. **`usp_PlaceOrder`** — atomic + error codes + ErrorLog  
3. **`ufn_GetCustomerOrderSummary`** — Inline TVF: OrderID, OrderDate, Status, LineCount, MerchandiseTotal, Freight  
4. **Trigger** อย่างน้อย 1: audit AFTER INSERT/UPDATE **หรือ** INSTEAD OF DELETE soft-delete (`Status = 'Cancelled'`)  
5. **Security notes** — user `ApiCaller`, GRANT EXECUTE / SELECT TVF, DENY ตาราง

## Security demo (ในคลาส)

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
-- เรียก proc/TVF ได้ — SELECT ตารางตรง ๆ ไม่ได้
REVERT;
```

ถ้า ownership chaining ขาด ให้พิจารณา `WITH EXECUTE AS OWNER`

## Hints

1. ทำให้ `usp_LogError` พร้อมก่อน  
2. CreateCustomer → PlaceOrder → TVF → Trigger  
3. Inline TVF = `RETURNS TABLE AS RETURN ( SELECT … )`  
4. Soft-delete ไม่ชน FK ของรายละเอียดออเดอร์  
5. ทดสอบทั้ง happy path และเคสสต็อก/ลูกค้าไม่ผ่าน

## Steps

1. `starter.sql`  
2. เทียบ `solution.sql`

## Prerequisites

Labs 05–07 · Workshop Day 1 · `setup/`
