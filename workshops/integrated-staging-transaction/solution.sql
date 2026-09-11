/*
==============================================================================
 Workshop — Integrated Staging Pattern | SOLUTION
 สคริปต์เต็ม + Production.usp_RestockLowStock
==============================================================================
*/
USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

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

CREATE OR ALTER PROCEDURE Production.usp_RestockLowStock
    @LowStockThreshold int = 40,
    @TargetQty         int = 50,
    @Note              nvarchar(200) = N'usp_RestockLowStock'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @TargetQty <= @LowStockThreshold
        THROW 53010, N'@TargetQty must be greater than @LowStockThreshold.', 1;

    IF OBJECT_ID(N'tempdb..#RestockBatch') IS NOT NULL
        DROP TABLE #RestockBatch;

    CREATE TABLE #RestockBatch
    (
        ProductID    int           NOT NULL PRIMARY KEY,
        ProductName  nvarchar(100) NOT NULL,
        MiniQty      int           NOT NULL,
        InventoryQty int           NOT NULL,
        TargetQty    int           NOT NULL,
        RestockQty   int           NOT NULL,
        IsValid      bit           NOT NULL
            CONSTRAINT DFT_usp_Restock_IsValid DEFAULT (1),
        RejectReason nvarchar(200) NULL
    );

    BEGIN TRY
        /* Phase A/B — query into staging */
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

        CREATE NONCLUSTERED INDEX IX_usp_Restock_Valid
        ON #RestockBatch (IsValid)
        INCLUDE (ProductID, RestockQty, MiniQty, TargetQty);

        /* Phase C — validate in temp only */
        UPDATE #RestockBatch
        SET IsValid = 0,
            RejectReason = N'RestockQty must be > 0'
        WHERE RestockQty <= 0;

        UPDATE #RestockBatch
        SET IsValid = 0,
            RejectReason = N'InventoryQty lower than TargetQty'
        WHERE IsValid = 1
          AND InventoryQty < TargetQty;

        IF NOT EXISTS (SELECT 1 FROM #RestockBatch WHERE IsValid = 1)
            THROW 53001, N'No valid rows in #RestockBatch — abort before opening a transaction.', 1;

        /* Phase D — transaction against real table */
        BEGIN TRANSACTION;

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

            INSERT INTO Production.StockAdjustLog
            (
                ProductID, QtyBefore, QtyAfter, Note
            )
            SELECT
                c.ProductID,
                c.QtyBefore,
                c.QtyAfter,
                @Note
            FROM @Changed AS c;

            IF (SELECT COUNT(*) FROM @Changed)
               <> (SELECT COUNT(*) FROM #RestockBatch WHERE IsValid = 1)
                THROW 53002, N'Row count mismatch between staging and update.', 1;

        COMMIT TRANSACTION;

        /* Result sets for caller / acceptance tests */
        SELECT
            ProductID, ProductName, MiniQty, InventoryQty,
            TargetQty, RestockQty, IsValid, RejectReason
        FROM #RestockBatch
        ORDER BY IsValid DESC, ProductID;

        SELECT ProductID, QtyBefore, QtyAfter
        FROM @Changed
        ORDER BY ProductID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        EXEC dbo.usp_LogError;
        THROW;
    END CATCH
END;
GO

/* Smoke test */
EXEC Production.usp_RestockLowStock
    @LowStockThreshold = 40,
    @TargetQty = 50,
    @Note = N'solution smoke test';
GO

SELECT ProductID, ProductName, Quantity
FROM Production.MiniProducts
WHERE ProductID IN (854, 859, 860);

SELECT TOP (10) *
FROM Production.StockAdjustLog
ORDER BY AdjustLogID DESC;
GO
