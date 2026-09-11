/*
==============================================================================
 Lab 05 — Stored Procedures | Instructor Demo
 Database: AdventureWorks  (เปลี่ยนเป็น AdventureWorks2022 ได้ตามเครื่อง Lab)
 Prerequisite: setup/01-create-lab-objects.sql
==============================================================================
*/
USE AdventureWorks;
GO

/* --------------------------------------------------------------------------
   0) Benefits of Stored Procedures (แนวคิด — อ่านประกอบ Demo)
   - Encapsulation / reuse business logic
   - Security: GRANT EXECUTE โดยไม่ต้อง GRANT ตารางตรง ๆ (ownership chaining)
   - Fewer round-trips / less ad-hoc SQL จากแอป
   - Plan reuse (พร้อมกับความเสี่ยง Parameter Sniffing)
   -------------------------------------------------------------------------- */

PRINT N'=== Lab 05 Demo: Stored Procedures ===';
GO

/* --------------------------------------------------------------------------
   1) CREATE PROC พื้นฐาน + SET NOCOUNT ON + หลีกเลี่ยง SELECT *
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_GetMiniCustomer
    @CustID int
AS
BEGIN
    SET NOCOUNT ON;  -- ลด "rows affected" messages

    -- ระบุคอลัมน์ชัดเจน แทน SELECT *
    SELECT
        c.CustID,
        c.CompanyName,
        c.ContactName,
        c.City,
        c.Country,
        c.IsActive
    FROM Sales.MiniCustomers AS c
    WHERE c.CustID = @CustID;
END;
GO

EXEC Sales.usp_GetMiniCustomer @CustID = 1;
GO

/* --------------------------------------------------------------------------
   2) Parameters: Input / OUTPUT / RETURN
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_GetCustomerOrderCount
    @CustID       int,
    @OrderCount   int OUTPUT,          -- ส่งค่ากลับผ่านตัวแปร
    @LatestStatus varchar(20) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Sales.MiniCustomers WHERE CustID = @CustID)
        RETURN 1;  -- status: not found

    SELECT
        @OrderCount = COUNT(*),
        @LatestStatus = MAX(o.Status)  -- ตัวอย่างเท่านั้น
    FROM Sales.MiniOrders AS o
    WHERE o.CustID = @CustID;

    RETURN 0;  -- status: success
END;
GO

DECLARE @cnt int, @status varchar(20), @rc int;
EXEC @rc = Sales.usp_GetCustomerOrderCount
    @CustID = 1,
    @OrderCount = @cnt OUTPUT,
    @LatestStatus = @status OUTPUT;

SELECT @rc AS ReturnCode, @cnt AS OrderCount, @status AS LatestStatus;
GO

/* --------------------------------------------------------------------------
   3) usp_LogError → dbo.ErrorLog + Error handling ใน Procedure
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_LogError
AS
BEGIN
    SET NOCOUNT ON;

    /* เรียกได้เฉพาะใน CATCH — ERROR_*() จะคืนค่าเมื่ออยู่ใน CATCH เท่านั้น */
    INSERT INTO dbo.ErrorLog
    (
        UserName,
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage,
        XactState
    )
    VALUES
    (
        SUSER_SNAME(),
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        XACT_STATE()
    );
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_AdjustMiniProductQty
    @ProductID int,
    @Delta     int  -- ติดลบ = ลดสต็อก
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE Production.MiniProducts
        SET Quantity = Quantity + @Delta
        WHERE ProductID = @ProductID;

        IF @@ROWCOUNT = 0
            THROW 50001, N'ProductID not found in MiniProducts.', 1;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        EXEC dbo.usp_LogError;

        DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
        THROW 50002, @msg, 1;  -- rethrow แบบมี contract ของ API
    END CATCH
END;
GO

-- Demo สำเร็จ
EXEC Sales.usp_AdjustMiniProductQty @ProductID = 854, @Delta = -1;

-- Demo ล้มเหลว (Product ไม่มี) → ดู ErrorLog
BEGIN TRY
    EXEC Sales.usp_AdjustMiniProductQty @ProductID = -999, @Delta = -1;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

SELECT TOP (5) * FROM dbo.ErrorLog ORDER BY ErrorLogID DESC;
GO

/* คืนสต็อกหลัง demo */
UPDATE Production.MiniProducts SET Quantity = Quantity + 1 WHERE ProductID = 854;
GO

/* --------------------------------------------------------------------------
   4) WITH ENCRYPTION (ปกป้อง definition — ไม่ใช่ strong security)
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_SecretGreeting
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SELECT N'Hello from encrypted procedure' AS Msg;
END;
GO

EXEC dbo.usp_SecretGreeting;

-- sp_helptext จะไม่แสดง source
EXEC sp_helptext N'dbo.usp_SecretGreeting';

SELECT
    OBJECT_DEFINITION(OBJECT_ID(N'dbo.usp_SecretGreeting')) AS DefinitionLooksNull;
GO

/* --------------------------------------------------------------------------
   5) EXECUTE AS / Security Context
   Ownership chaining: caller มี EXECUTE บน proc → อ่านตารางของเจ้าของ schema ได้
   EXECUTE AS เปลี่ยน context เป็น user อื่นภายใน procedure
   -------------------------------------------------------------------------- */
IF USER_ID(N'LabAppUser') IS NULL
    CREATE USER LabAppUser WITHOUT LOGIN;
GO

-- ลบสิทธิ์ตารางจาก LabAppUser (ถ้ามี) — ให้พึ่ง EXECUTE บน procedure
DENY SELECT ON Sales.MiniCustomers TO LabAppUser;
GO

CREATE OR ALTER PROCEDURE Sales.usp_GetMiniCustomer_AsOwner
    @CustID int
WITH EXECUTE AS OWNER  -- รันด้วยสิทธิ์เจ้าของ module
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CustID, CompanyName, City
    FROM Sales.MiniCustomers
    WHERE CustID = @CustID;
END;
GO

GRANT EXECUTE ON Sales.usp_GetMiniCustomer_AsOwner TO LabAppUser;
GO

-- จำลองการเรียกในฐานะ LabAppUser
EXECUTE AS USER = N'LabAppUser';
    -- SELECT ตรง ๆ จะล้มเหลว (DENY)
    BEGIN TRY
        SELECT TOP (1) CustID FROM Sales.MiniCustomers;
    END TRY
    BEGIN CATCH
        SELECT N'Direct SELECT blocked' AS Note, ERROR_MESSAGE() AS ErrMsg;
    END CATCH;

    -- ผ่าน procedure สำเร็จ
    EXEC Sales.usp_GetMiniCustomer_AsOwner @CustID = 1;
REVERT;
GO

/* --------------------------------------------------------------------------
   6) Parameter Sniffing — ปัญหา + Mitigation
   แนวคิด: plan ที่ compile ด้วยค่า parameter แรกถูก cache แล้วใช้ซ้ำกับค่าอื่น
   -------------------------------------------------------------------------- */

-- เตรียม proc ที่ sniffer ได้ง่าย (ใช้ AdventureWorks Sales.SalesOrderDetail)
CREATE OR ALTER PROCEDURE Sales.usp_OrdersByProduct_Sniff
    @ProductID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sod.SalesOrderID, sod.OrderQty, sod.UnitPrice
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.ProductID = @ProductID;
END;
GO

/* เคลียร์ plan ของ proc นี้ (demo เท่านั้น — อย่าทำบน production โดยไม่คิด) */
DECLARE @plan_handle varbinary(64);
SELECT @plan_handle = qs.plan_handle
FROM sys.dm_exec_procedure_stats AS qs
WHERE qs.object_id = OBJECT_ID(N'Sales.usp_OrdersByProduct_Sniff');
IF @plan_handle IS NOT NULL
    DBCC FREEPROCCACHE(@plan_handle);
GO

/*
   Demo flow (Instructor):
   1) รันด้วย ProductID ที่แถวน้อย → plan อาจเป็น Nested Loop / Seek
   2) รันด้วย ProductID ที่แถวเยอะโดยไม่ recompile → อาจใช้ plan เดิม (sniff)
   ใช้ Actual Execution Plan ใน SSMS เพื่อเปรียบเทียบ
*/
-- ค่าที่มีแถวน้อย / มาก ขึ้นกับข้อมูล AdventureWorks ของเครื่อง — ปรับได้
EXEC Sales.usp_OrdersByProduct_Sniff @ProductID = 870;  -- มักมีหลายแถว
EXEC Sales.usp_OrdersByProduct_Sniff @ProductID = 897;  -- มักมีน้อยแถว
GO

/* --- Mitigation A: OPTIMIZE FOR --- */
CREATE OR ALTER PROCEDURE Sales.usp_OrdersByProduct_OptimizeFor
    @ProductID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sod.SalesOrderID, sod.OrderQty, sod.UnitPrice
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.ProductID = @ProductID
    OPTION (OPTIMIZE FOR (@ProductID = 870));  -- บังคับ density ตามค่าที่เลือก
END;
GO

/* --- Mitigation B: Local variable (ลด sniff — ใช้ density เฉลี่ย) --- */
CREATE OR ALTER PROCEDURE Sales.usp_OrdersByProduct_LocalVar
    @ProductID int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @pid int = @ProductID;  -- optimizer มองไม่เห็นค่าจริงตอน compile

    SELECT sod.SalesOrderID, sod.OrderQty, sod.UnitPrice
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.ProductID = @pid;
END;
GO

/* --- Mitigation C: RECOMPILE (ได้ plan ใหม่ทุกครั้ง — แลก CPU) --- */
CREATE OR ALTER PROCEDURE Sales.usp_OrdersByProduct_Recompile
    @ProductID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sod.SalesOrderID, sod.OrderQty, sod.UnitPrice
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.ProductID = @ProductID
    OPTION (RECOMPILE);
END;
GO

PRINT N'Mitigation demos ready: OptimizeFor / LocalVar / Recompile';
GO

/* --------------------------------------------------------------------------
   6b) SQL Server 2025 / compat 170 — engine-side help (conceptual)
   - Parameter Sensitive Plan (PSP): ตั้งแต่ 2022 สำหรับ SELECT;
     ใน 2025 ขยายไป DML (INSERT/UPDATE/DELETE/MERGE) ที่ compatibility_level = 170
   - Optional Parameter Plan Optimization (OPPO): แยก plan เมื่อพารามิเตอร์เป็น NULL vs NOT NULL
   Mitigation ด้านบนยังจำเป็นเมื่อต้องการควบคุมชัดเจน / เวอร์ชันเก่ากว่า 2025
   เอกสาร: https://learn.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing
   -------------------------------------------------------------------------- */
SELECT name, compatibility_level
FROM sys.databases
WHERE name = DB_NAME();

PRINT N'ถ้า compatibility_level >= 170 บน SQL Server 2025 — พูดถึง PSP-for-DML และ OPPO หลัง mitigation แบบ manual';
GO

/* --------------------------------------------------------------------------
   7) Nested Procedures
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE Sales.usp_ResolveCustomerName
    @CustID int,
    @Name   nvarchar(40) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Name = CompanyName
    FROM Sales.MiniCustomers
    WHERE CustID = @CustID;

    IF @Name IS NULL
        THROW 50010, N'Customer not found.', 1;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_PrintCustomerCard
    @CustID int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @name nvarchar(40);

    PRINT N'NestLevel before nested call: ' + CAST(@@NESTLEVEL AS varchar(3));
    EXEC Sales.usp_ResolveCustomerName @CustID = @CustID, @Name = @name OUTPUT;
    PRINT N'NestLevel after nested call:  ' + CAST(@@NESTLEVEL AS varchar(3));

    SELECT @CustID AS CustID, @name AS CompanyName, @@NESTLEVEL AS NestLevelNow;
END;
GO

EXEC Sales.usp_PrintCustomerCard @CustID = 2;
GO

/* --------------------------------------------------------------------------
   8) OUTPUT clause / OUTPUT INSERTED — จับค่าจาก INSERT โดยไม่พึ่ง SCOPE_IDENTITY อย่างเดียว
      สำคัญเมื่อมี Trigger / insert หลายแถว
   -------------------------------------------------------------------------- */
DECLARE @InsertedOrders TABLE
(
    OrderID int NOT NULL,
    CustID  int NULL,
    Status  varchar(20) NOT NULL
);

INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
OUTPUT inserted.OrderID, inserted.CustID, inserted.Status
INTO @InsertedOrders (OrderID, CustID, Status)
VALUES (1, N'DEMO-OUTPUT', 0, 'Open');

SELECT * FROM @InsertedOrders;  -- ได้ OrderID ที่เพิ่ง insert แม้มี trigger ภายหลัง

-- cleanup demo row (detail ไม่มี)
DELETE d
FROM Sales.MiniOrderDetails AS d
WHERE d.OrderID IN (SELECT OrderID FROM @InsertedOrders);

DELETE o
FROM Sales.MiniOrders AS o
WHERE o.OrderID IN (SELECT OrderID FROM @InsertedOrders);
GO

/* --------------------------------------------------------------------------
   9) Table-Valued Parameter (TVP) — ส่งหลายบรรทัดเข้า Procedure เป็นชุด
   -------------------------------------------------------------------------- */
IF TYPE_ID(N'Sales.OrderLineType') IS NOT NULL
BEGIN
    -- ต้อง drop proc ที่อ้าง type ก่อน (ถ้ามี)
    IF OBJECT_ID(N'Sales.usp_PreviewOrderLines', N'P') IS NOT NULL
        DROP PROCEDURE Sales.usp_PreviewOrderLines;
    IF OBJECT_ID(N'Sales.usp_PlaceOrderLines', N'P') IS NOT NULL
        DROP PROCEDURE Sales.usp_PlaceOrderLines;
    DROP TYPE Sales.OrderLineType;
END
GO

CREATE TYPE Sales.OrderLineType AS TABLE
(
    ProductID int      NOT NULL,
    Quantity  smallint NOT NULL CHECK (Quantity > 0),
    UnitPrice money    NOT NULL CHECK (UnitPrice >= 0),
    Discount  numeric(4, 3) NOT NULL DEFAULT (0)
);
GO

CREATE OR ALTER PROCEDURE Sales.usp_PreviewOrderLines
    @Lines Sales.OrderLineType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ProductID,
        Quantity,
        UnitPrice,
        Discount,
        Quantity * UnitPrice * (1 - Discount) AS LineTotal
    FROM @Lines;
END;
GO

DECLARE @t Sales.OrderLineType;
INSERT INTO @t (ProductID, Quantity, UnitPrice, Discount)
VALUES
    (854, 2, 100.00, 0.00),
    (859, 1, 250.00, 0.10);

EXEC Sales.usp_PreviewOrderLines @Lines = @t;
GO

PRINT N'=== Lab 05 Demo complete (OUTPUT INSERTED + TVP) ===';
GO
