# SSMS 22 — Git และ SQL Project

คู่มือสั้นสำหรับ Instructor / ผู้เรียนที่ใช้ [SSMS 22 Database DevOps](https://learn.microsoft.com/en-us/ssms/database-devops)

> **สำคัญ:** โปรเจกต์นี้เป็น **SDK-style `Microsoft.Build.Sql`**  
> เปิดได้ใน **SSMS 22 (+ Database DevOps workload)** / VS Code / `dotnet build`  
> **เปิดด้วย Visual Studio แล้วขึ้น Unsupported ได้** — เป็นเรื่องปกติ ไม่ใช่ไฟล์เสีย

## สิ่งที่มีใน Repo

| รายการ | path |
|--------|------|
| Lab DB project (เปิดอันนี้ใน SSMS) | `src/SqlPgSp.LabDb/SqlPgSp.LabDb.sqlproj` |
| Solution (ทางเลือก ใน SSMS เท่านั้น) | `SqlPgSp.sln` |
| สคริปต์เปิด SSMS | `scripts/open-labdb-in-ssms.ps1` |
| Lab / Workshop scripts | `labs/`, `workshops/` (ไม่ได้อยู่ใน sqlproj) |
| Setup แบบสคริปต์ (AdventureWorks) | `setup/01-create-lab-objects.sql` |

## แยกบทบาทให้ชัด

| ใช้เมื่อ | เครื่องมือ |
|---------|-----------|
| เรียน demo / exercise / concurrency 2 sessions | สคริปต์ใน `labs/` บน **AdventureWorks** |
| จัดการ schema Lab เป็น source control + Build/Publish | **SqlPgSp.LabDb** → database `SqlPgSpLab` |
| เก็บประวัติเนื้อหาคอร์ส | **Git** (remote GitHub) |

อย่า publish dacpac ของ LabDb เข้า AdventureWorks โดยเปิด `DropObjectsNotInSource=True` — จะพยายามลบ object ที่ไม่อยู่ในโปรเจกต์

## ติดตั้ง SSMS 22 workload (จำเป็น)

ถ้าเปิดแล้วขึ้น **Unsupported / project types may not be installed**:

1. ตรวจว่าเปิดด้วย **SSMS 22** ไม่ใช่ Visual Studio  
   - บน Windows ดับเบิลคลิก `.sln` มักเปิด **Visual Studio** → จะขึ้นข้อความนี้เสมอ  
2. ปิดโปรแกรม แล้วเปิด **Visual Studio Installer**  
3. **Modify** ที่รายการ **SQL Server Management Studio 22**  
4. ติ๊ก workload **Database DevOps** → Modify/Install  
5. เปิด SSMS 22 ใหม่ (แนะนำ 22.4+)

เพิ่มเติม: ติดตั้ง .NET SDK สำหรับ `dotnet build` จาก CLI

## วิธีเปิดที่ถูกต้อง

### แนะนำ (หลีกเลี่ยง Visual Studio)

```powershell
.\scripts\open-labdb-in-ssms.ps1
```

หรือใน SSMS 22:

1. **File** → **Open** → **Project/Solution…**
2. เลือก `src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj`  
   (หรือ `SqlPgSp.sln` ก็ได้ แต่ต้องเปิดจากใน SSMS)
3. Solution Explorer ต้องเห็นโหนด **SqlPgSp.LabDb** และโฟลเดอร์ schema

### ถ้ายัง Unsupported

| สาเหตุ | แก้ |
|--------|-----|
| เปิดด้วย Visual Studio | ปิด VS → เปิดด้วย SSMS 22 ตามด้านบน |
| SSMS ไม่มี Database DevOps | Modify installer แล้วติ๊ก workload |
| เปิดแค่โฟลเดอร์ repo | ใช้ Open Project/Solution เลือก `.sqlproj` |
| ต้องการยืนยันว่าไฟล์ไม่พัง | `dotnet build .\src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj` ต้องสำเร็จ |

เอกสารอ้างอิง: [Database DevOps in SSMS](https://learn.microsoft.com/en-us/ssms/database-devops) — *SSMS supports SDK-style Microsoft.Build.Sql projects only*

## Build / Publish

### จาก SSMS
1. คลิกขวาโปรเจกต์ `SqlPgSp.LabDb` → **Build**
2. คลิกขวา → **Publish…**
3. Target: สร้าง/ชี้ไปที่ database ชื่อ `SqlPgSpLab`
4. ตรวจว่า **Drop objects not in source = False**

### จาก CLI (ใช้ได้แม้ยังไม่มี UI ใน IDE)

```powershell
dotnet build .\src\SqlPgSp.LabDb\SqlPgSp.LabDb.sqlproj
```

ได้ `.dacpac` ที่ `src\SqlPgSp.LabDb\bin\Debug\`

คัดลอก publish profile:

```powershell
Copy-Item .\src\SqlPgSp.LabDb\PublishProfiles\SqlPgSpLab.publish.xml.example `
          .\src\SqlPgSp.LabDb\PublishProfiles\SqlPgSpLab.publish.xml
# แก้ connection string แล้ว publish ด้วย SqlPackage หรือ UI ใน SSMS
```

## Workflow ที่แนะนำในคลาส

| วัน | กิจกรรม |
|-----|---------|
| Day 1 เช้า | Clone repo ด้วย Git ใน SSMS → รัน `setup/` บน AdventureWorks |
| Day 1–2 | ทำ labs/workshops ด้วย query window ตามเดิม |
| Day 2 ท้าย (ทางเลือก 15–20 นาที) | รัน `scripts/open-labdb-in-ssms.ps1` → Build/Publish `SqlPgSpLab` |

## Object ใน SqlPgSp.LabDb

- Schemas: `Production`, `Sales`
- Tables: `MiniProducts`, `MiniCustomers`, `MiniOrders`, `MiniOrderDetails`, `MiniOrdersAudit`, `dbo.ErrorLog`
- Procs: `dbo.usp_LogError`, `Sales.usp_CreateCustomer`, `Sales.usp_PlaceOrder`
- Function: `Sales.ufn_GetCustomerOrderSummary`
- Triggers: soft-delete + audit บน `MiniOrders`
- PostDeploy: seed ลูกค้า 1–3 และสินค้า 854/859/860
