/*
==============================================================================
 Workshop — Integrated Staging Pattern | INSTRUCTOR DEMO
 เฟส: Query → #temp → Validate → TRAN Update (+ OUTPUT) → (optional) Procedure

 Database: AdventureWorks / AdventureWorks2022
 Prerequisite: setup/01-create-lab-objects.sql
==============================================================================
*/
USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/* --------------------------------------------------------------------------
   0) Helper: Error logger (สร้างถ้ายังไม่มี)
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.usp_LogError
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ErrorLog
    (
        UserName, ErrorNumber, ErrorSeverity, ErrorState,
        ErrorProcedure, ErrorLine, ErrorMessage, XactState
    )
    VALUES
    (
        SUSER_SNAME(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
        ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), XACT_STATE()
    );
END;
GO

/* --------------------------------------------------------------------------
   0b) ตารางบันทึกผลการปรับสต็อก (object ถาวรเล็ก ๆ สำหรับ workshop)
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Production.StockAdjustLog', N'U') IS NULL
BEGIN
    CREATE TABLE Production.StockAdjustLog
    (
        AdjustLogID   int IDENTITY(1, 1) NOT NULL
            CONSTRAINT PK_StockAdjustLog PRIMARY KEY,
        AdjustUtc     datetime2(3) NOT NULL
            CONSTRAINT DFT_StockAdjustLog_AdjustUtc DEFAULT (SYSUTCDATETIME()),
        ProductID     int NOT NULL,
        QtyBefore     int NOT NULL,
        QtyAfter      int NOT NULL,
        AdjustedBy    sysname NOT NULL
            CONSTRAINT DFT_StockAdjustLog_AdjustedBy DEFAULT (SUSER_SNAME()),
        Note          nvarchar(200) NULL
    );
END
GO

/* ==========================================================================
   PHASE A — สืบค้นข้อมูลต้นทาง (ยังไม่แตะ MiniProducts)
   รวมยอดคลังจริงจาก ProductInventory เทียบกับ MiniProducts
   ========================================================================== */
DECLARE @LowStockThreshold int = 40;   -- สินค้าที่ MiniProducts.Quantity ต่ำกว่านี้
DECLARE @TargetQty         int = 50;   -- เติมให้ถึงจุดนี้

SELECT
    mp.ProductID,
    mp.ProductName,
    mp.Quantity AS MiniQty,
    InventoryQty = SUM(ISNULL(i.Quantity, 0)),
    @TargetQty AS TargetQty,
    RestockQty = @TargetQty - mp.Quantity
FROM Production.MiniProducts AS mp
INNER JOIN Production.ProductInventory AS i
    ON i.ProductID = mp.ProductID
WHERE mp.ProductID IN (854, 859, 860)   -- โฟกัสสินค้า lab; เอาออกได้ถ้าต้องการทั้งตาราง
GROUP BY mp.ProductID, mp.ProductName, mp.Quantity
HAVING mp.Quantity < @LowStockThreshold;
GO

/* ==========================================================================
   PHASE B — ลง #temp (staging)
   ใช้ #temp เพราะ: หลายขั้น, สร้าง index ได้, มี statistics ดีกว่า table variable
   ========================================================================== */
IF OBJECT_ID(N'tempdb..#RestockBatch') IS NOT NULL
    DROP TABLE #RestockBatch;
GO

CREATE TABLE #RestockBatch
(
    ProductID    int           NOT NULL PRIMARY KEY,
    ProductName  nvarchar(100) NOT NULL,
    MiniQty      int           NOT NULL,
    InventoryQty int           NOT NULL,
    TargetQty    int           NOT NULL,
    RestockQty   int           NOT NULL,
    IsValid      bit           NOT NULL
        CONSTRAINT DFT_RestockBatch_IsValid DEFAULT (1),
    RejectReason nvarchar(200) NULL
);

DECLARE @LowStockThreshold int = 40;
DECLARE @TargetQty         int = 50;

INSERT INTO #RestockBatch
(
    ProductID, ProductName, MiniQty, InventoryQty, TargetQty, RestockQty
)
SELECT
    mp.ProductID,
    mp.ProductName,
    mp.Quantity,
    InventoryQty = SUM(ISNULL(i.Quantity, 0)),
    @TargetQty,
    RestockQty = @TargetQty - mp.Quantity
FROM Production.MiniProducts AS mp
INNER JOIN Production.ProductInventory AS i
    ON i.ProductID = mp.ProductID
WHERE mp.ProductID IN (854, 859, 860)
GROUP BY mp.ProductID, mp.ProductName, mp.Quantity
HAVING mp.Quantity < @LowStockThreshold;

CREATE NONCLUSTERED INDEX IX_RestockBatch_Valid
ON #RestockBatch (IsValid)
INCLUDE (ProductID, RestockQty, MiniQty, TargetQty);

SELECT * FROM #RestockBatch;
GO

/* ==========================================================================
   PHASE C — ตรวจสอบ / ปรับแต่งใน #temp (ยังไม่เขียนตารางจริง)
   ========================================================================== */
-- กฎ: RestockQty ต้อง > 0
UPDATE #RestockBatch
SET IsValid = 0,
    RejectReason = N'RestockQty must be > 0'
WHERE RestockQty <= 0;

-- กฎ: คลังจริงควรมีของเพียงพออย่างน้อยเท่าที่เติม (ตัวอย่างธุรกิจ)
UPDATE #RestockBatch
SET IsValid = 0,
    RejectReason = N'InventoryQty lower than TargetQty'
WHERE IsValid = 1
  AND InventoryQty < TargetQty;

SELECT
    ProductID, ProductName, MiniQty, InventoryQty, TargetQty, RestockQty,
    IsValid, RejectReason
FROM #RestockBatch
ORDER BY IsValid DESC, ProductID;

DECLARE @ValidCount int = (SELECT COUNT(*) FROM #RestockBatch WHERE IsValid = 1);
IF @ValidCount = 0
    THROW 53001, N'No valid rows in #RestockBatch — abort before opening a transaction.', 1;

PRINT CONCAT(N'Valid rows ready for update: ', @ValidCount);
GO

/* ==========================================================================
   PHASE D — Transaction: ปรับปรุง MiniProducts จาก #temp + OUTPUT หลักฐาน
   Best practices รวม: XACT_ABORT, TRY/CATCH, XACT_STATE, UPDLOCK, OUTPUT, ErrorLog
   ========================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        /* ล็อกแถวปลายทางที่จะอัปเดต (กัน lost update แบบง่าย) */
        DECLARE @Locked TABLE (ProductID int PRIMARY KEY, QtyBefore int NOT NULL);

        INSERT INTO @Locked (ProductID, QtyBefore)
        SELECT p.ProductID, p.Quantity
        FROM Production.MiniProducts AS p WITH (UPDLOCK, ROWLOCK)
        INNER JOIN #RestockBatch AS b
            ON b.ProductID = p.ProductID
           AND b.IsValid = 1;

        DECLARE @Changed TABLE
        (
            ProductID int NOT NULL,
            QtyBefore int NOT NULL,
            QtyAfter  int NOT NULL
        );

        UPDATE p
        SET p.Quantity = b.TargetQty
        OUTPUT
            deleted.ProductID,
            deleted.Quantity,
            inserted.Quantity
        INTO @Changed (ProductID, QtyBefore, QtyAfter)
        FROM Production.MiniProducts AS p
        INNER JOIN #RestockBatch AS b
            ON b.ProductID = p.ProductID
           AND b.IsValid = 1
        INNER JOIN @Locked AS l
            ON l.ProductID = p.ProductID;

        /* บันทึกหลักฐานลง log ถาวร */
        INSERT INTO Production.StockAdjustLog
        (
            ProductID, QtyBefore, QtyAfter, Note
        )
        SELECT
            c.ProductID,
            c.QtyBefore,
            c.QtyAfter,
            N'Integrated staging demo: restock to target'
        FROM @Changed AS c;

        /* ความถูกต้อง: จำนวนแถวที่เปลี่ยนต้องเท่าจำนวน valid */
        IF (SELECT COUNT(*) FROM @Changed)
           <> (SELECT COUNT(*) FROM #RestockBatch WHERE IsValid = 1)
            THROW 53002, N'Row count mismatch between staging and update.', 1;

        COMMIT TRANSACTION;

        SELECT N'COMMITTED' AS Result, * FROM @Changed;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    EXEC dbo.usp_LogError;

    SELECT
        ERROR_NUMBER()  AS ErrNo,
        ERROR_MESSAGE() AS ErrMsg,
        XACT_STATE()    AS XactState;

    THROW;
END CATCH
SET XACT_ABORT OFF;
GO

/* ตรวจผลหลัง commit */
SELECT ProductID, ProductName, Quantity
FROM Production.MiniProducts
WHERE ProductID IN (854, 859, 860);

SELECT TOP (10) *
FROM Production.StockAdjustLog
ORDER BY AdjustLogID DESC;
GO

/* ==========================================================================
   PHASE E — สรุป: สคริปต์สำรวจ → object ที่เรียกซ้ำได้
   (ดู solution.sql สำหรับ usp_RestockLowStock ที่ห่อ pattern นี้)
   ========================================================================== */
PRINT N'Demo complete: Query → #temp → validate → TRAN+OUTPUT → log';
PRINT N'Next: exercise.sql / solution.sql (wrap as procedure)';
GO
