/*
==============================================================================
 Lab 07 — DML Triggers | Instructor Demo
 Database: AdventureWorks  (หรือ AdventureWorks2022)
 Prerequisite: setup/01-create-lab-objects.sql
==============================================================================
*/
USE AdventureWorks;
GO

PRINT N'=== Lab 07 Demo: Triggers ===';
GO

/* --------------------------------------------------------------------------
   0) ตาราง Audit สำหรับ MiniOrders
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Sales.MiniOrdersAudit', N'U') IS NOT NULL
    DROP TABLE Sales.MiniOrdersAudit;
GO

CREATE TABLE Sales.MiniOrdersAudit
(
    AuditID     int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_MiniOrdersAudit PRIMARY KEY,
    OrderID     int NOT NULL,
    ActionType  char(1) NOT NULL,  -- I / U / D
    ActionUtc   datetime2(0) NOT NULL
        CONSTRAINT DFT_MiniOrdersAudit_ActionUtc DEFAULT (SYSUTCDATETIME()),
    Actor       sysname NOT NULL
        CONSTRAINT DFT_MiniOrdersAudit_Actor DEFAULT (ORIGINAL_LOGIN()),
    OldStatus   varchar(20) NULL,
    NewStatus   varchar(20) NULL,
    OldFreight  money NULL,
    NewFreight  money NULL
);
GO

/* --------------------------------------------------------------------------
   1) AFTER INSERT — ใช้ inserted
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterInsert
ON Sales.MiniOrders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sales.MiniOrdersAudit (OrderID, ActionType, NewStatus, NewFreight)
    SELECT i.OrderID, 'I', i.Status, i.Freight
    FROM inserted AS i;
END;
GO

INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
VALUES (1, 'PO-TRG-INS', 15.00, 'Open');

SELECT TOP (5) * FROM Sales.MiniOrdersAudit ORDER BY AuditID DESC;
GO

/* --------------------------------------------------------------------------
   2) AFTER UPDATE — inserted + deleted + UPDATE()
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterUpdate
ON Sales.MiniOrders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ตัวอย่าง: ถ้ามีการเปลี่ยน Status หรือ Freight ให้ audit
    IF UPDATE(Status) OR UPDATE(Freight)
    BEGIN
        INSERT INTO Sales.MiniOrdersAudit
        (
            OrderID, ActionType, OldStatus, NewStatus, OldFreight, NewFreight
        )
        SELECT
            i.OrderID,
            'U',
            d.Status,
            i.Status,
            d.Freight,
            i.Freight
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.OrderID = i.OrderID;
    END;

    -- บันทึก metadata บนแถว (ระวัง recursive trigger!)
    UPDATE o
    SET
        o.LastModifiedUtc = SYSUTCDATETIME(),
        o.ModifiedBy = ORIGINAL_LOGIN()
    FROM Sales.MiniOrders AS o
    INNER JOIN inserted AS i ON i.OrderID = o.OrderID;
END;
GO

UPDATE Sales.MiniOrders
SET Freight = Freight + 1, Status = 'Open'
WHERE PurchaseOrderNumber = 'PO-TRG-INS';

SELECT TOP (5) * FROM Sales.MiniOrdersAudit ORDER BY AuditID DESC;
SELECT OrderID, Freight, Status, LastModifiedUtc, ModifiedBy
FROM Sales.MiniOrders
WHERE PurchaseOrderNumber = 'PO-TRG-INS';
GO

/* --------------------------------------------------------------------------
   3) AFTER DELETE
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterDelete
ON Sales.MiniOrders
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sales.MiniOrdersAudit (OrderID, ActionType, OldStatus, OldFreight)
    SELECT d.OrderID, 'D', d.Status, d.Freight
    FROM deleted AS d;
END;
GO

-- ลบแถว demo (ถ้ามี details ต้องลบ details ก่อน)
DELETE d
FROM Sales.MiniOrderDetails AS d
INNER JOIN Sales.MiniOrders AS o ON o.OrderID = d.OrderID
WHERE o.PurchaseOrderNumber = 'PO-TRG-INS';

DELETE FROM Sales.MiniOrders WHERE PurchaseOrderNumber = 'PO-TRG-INS';

SELECT TOP (5) * FROM Sales.MiniOrdersAudit ORDER BY AuditID DESC;
GO

/* --------------------------------------------------------------------------
   4) INSTEAD OF DELETE — Soft delete ผ่าน Status flag
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_InsteadOfDelete
ON Sales.MiniOrders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET
        o.Status = 'Cancelled',
        o.LastModifiedUtc = SYSUTCDATETIME(),
        o.ModifiedBy = ORIGINAL_LOGIN()
    FROM Sales.MiniOrders AS o
    INNER JOIN deleted AS d ON d.OrderID = o.OrderID
    WHERE o.Status <> 'Cancelled';

    INSERT INTO Sales.MiniOrdersAudit (OrderID, ActionType, OldStatus, NewStatus)
    SELECT d.OrderID, 'D', d.Status, 'Cancelled'
    FROM deleted AS d;
END;
GO

-- เตรียมแถวแล้ว "ลบ" → กลายเป็น Cancelled
INSERT INTO Sales.MiniOrders (CustID, PurchaseOrderNumber, Freight, Status)
VALUES (2, 'PO-SOFT-DEL', 9.00, 'Open');

DECLARE @oid int = SCOPE_IDENTITY();

DELETE FROM Sales.MiniOrders WHERE OrderID = @oid;

SELECT OrderID, Status, LastModifiedUtc
FROM Sales.MiniOrders
WHERE OrderID = @oid;  -- แถวยังอยู่ Status = Cancelled
GO

/* หมายเหตุ: ตารางมีได้หลาย AFTER ต่อ event แต่ INSTEAD OF ต่อ event มีได้หนึ่งตัว
   ถ้าต้องการ AFTER DELETE จริง ต้อง DROP INSTEAD OF ก่อน หรือแยกตาราง
*/

/* --------------------------------------------------------------------------
   5) Nested triggers (trigger บนตาราง A เขียนตาราง B → ยิง trigger B)
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Sales.MiniOrderNotes', N'U') IS NOT NULL
    DROP TABLE Sales.MiniOrderNotes;
GO

CREATE TABLE Sales.MiniOrderNotes
(
    NoteID    int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    OrderID   int NOT NULL,
    NoteText  nvarchar(200) NOT NULL,
    CreatedUtc datetime2(0) NOT NULL DEFAULT (SYSUTCDATETIME())
);
GO

CREATE OR ALTER TRIGGER Sales.trg_MiniOrderNotes_AfterInsert
ON Sales.MiniOrderNotes
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'[Nested] MiniOrderNotes AFTER INSERT fired. NestLevel='
        + CAST(@@NESTLEVEL AS varchar(3));
END;
GO

-- ปิด INSTEAD OF ชั่วคราวเพื่อโชว์ AFTER UPDATE ที่ insert notes
DROP TRIGGER IF EXISTS Sales.trg_MiniOrders_InsteadOfDelete;
GO

CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterUpdate_WriteNote
ON Sales.MiniOrders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        INSERT INTO Sales.MiniOrderNotes (OrderID, NoteText)
        SELECT i.OrderID, N'Status changed to ' + i.Status
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.OrderID = i.OrderID
        WHERE ISNULL(i.Status, '') <> ISNULL(d.Status, '');
        -- INSERT นี้จะยิง trg_MiniOrderNotes_AfterInsert (nested)
    END
END;
GO

UPDATE Sales.MiniOrders
SET Status = 'Shipped'
WHERE PurchaseOrderNumber = 'PO-SOFT-DEL';

SELECT * FROM Sales.MiniOrderNotes;
GO

/* Nested triggers option ที่ระดับ server (ค่าเริ่มต้น 1 = ON) */
-- EXEC sp_configure 'nested triggers';  -- ดูค่า (อาจต้อง show advanced)
GO

/* --------------------------------------------------------------------------
   6) Recursive triggers (trigger อัปเดตตารางตัวเอง)
   Database option: RECURSIVE_TRIGGERS OFF เป็นค่าเริ่มต้น
   -------------------------------------------------------------------------- */
SELECT name, is_recursive_triggers_on
FROM sys.databases
WHERE name = DB_NAME();
GO

/*
  ถ้าเปิด RECURSIVE_TRIGGERS ON — trg ที่ UPDATE ตารางเดียวกันอาจวน
  Demo metadata update ในข้อ 2 อาจวนถ้าเปิด recursive + ไม่กันเงื่อนไข
  แนวทางกัน: IF UPDATE(col) เฉพาะคอลัมน์ธุรกิจ หรือไม่ update คอลัมน์ที่ trigger เขียนเอง
*/

/* --------------------------------------------------------------------------
   7) sp_settriggerorder — กำหนด first / last ของ AFTER ต่อ event
   -------------------------------------------------------------------------- */
CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterUpdate_First
ON Sales.MiniOrders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'[Order] FIRST trigger';
END;
GO

CREATE OR ALTER TRIGGER Sales.trg_MiniOrders_AfterUpdate_Last
ON Sales.MiniOrders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'[Order] LAST trigger';
END;
GO

EXEC sp_settriggerorder
    @triggername = N'Sales.trg_MiniOrders_AfterUpdate_First',
    @order = 'First',
    @stmttype = 'UPDATE';

EXEC sp_settriggerorder
    @triggername = N'Sales.trg_MiniOrders_AfterUpdate_Last',
    @order = 'Last',
    @stmttype = 'UPDATE';
GO

UPDATE Sales.MiniOrders
SET Freight = Freight + 0.01
WHERE PurchaseOrderNumber = 'PO-SOFT-DEL';
GO

/* --------------------------------------------------------------------------
   8) Performance considerations + when NOT to use
   - Trigger ทำงานใน transaction เดียวกับ DML → หน่วง statement เดิม
   - หลีกเลี่ยง cursor / remote call / query หนักใน trigger
   - อย่าใช้แทน validation ที่ constraint ทำได้
   - เอกสารให้ทีมรู้ว่ามี side-effect
   -------------------------------------------------------------------------- */
PRINT N'Performance: keep triggers thin, set-based, and well-documented.';
GO

PRINT N'=== Lab 07 Demo complete ===';
GO
