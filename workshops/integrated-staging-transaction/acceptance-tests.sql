/*
==============================================================================
 Workshop — Integrated Staging Pattern | ACCEPTANCE TESTS
 Run after solution.sql (or after learner completes exercise)
==============================================================================
*/
USE AdventureWorks;
GO

SET NOCOUNT ON;

DECLARE @Failed int = 0;

/* T01 — procedure exists */
IF OBJECT_ID(N'Production.usp_RestockLowStock', N'P') IS NULL
BEGIN
    PRINT N'FAIL T01: Production.usp_RestockLowStock missing';
    SET @Failed += 1;
END
ELSE
    PRINT N'PASS T01: procedure exists';

/* T02 — StockAdjustLog exists */
IF OBJECT_ID(N'Production.StockAdjustLog', N'U') IS NULL
BEGIN
    PRINT N'FAIL T02: Production.StockAdjustLog missing';
    SET @Failed += 1;
END
ELSE
    PRINT N'PASS T02: StockAdjustLog exists';

/* T03 — reset sample products to low stock, then restock */
UPDATE Production.MiniProducts
SET Quantity = 10
WHERE ProductID IN (854, 859, 860);

DECLARE @BeforeLog int = (SELECT COUNT(*) FROM Production.StockAdjustLog);

BEGIN TRY
    EXEC Production.usp_RestockLowStock
        @LowStockThreshold = 40,
        @TargetQty = 50,
        @Note = N'acceptance T03';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'FAIL T03: procedure raised error — ', ERROR_MESSAGE());
    SET @Failed += 1;
END CATCH;

IF EXISTS (
    SELECT 1
    FROM Production.MiniProducts
    WHERE ProductID IN (854, 859, 860)
      AND Quantity <> 50
)
BEGIN
    PRINT N'FAIL T03: MiniProducts not restocked to 50';
    SET @Failed += 1;
END
ELSE IF (SELECT COUNT(*) FROM Production.StockAdjustLog) <= @BeforeLog
BEGIN
    PRINT N'FAIL T03: no new StockAdjustLog rows';
    SET @Failed += 1;
END
ELSE
    PRINT N'PASS T03: restock + log';

/* T04 — invalid params must fail without changing data */
UPDATE Production.MiniProducts
SET Quantity = 10
WHERE ProductID = 854;

DECLARE @QtyBefore int =
(
    SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854
);

BEGIN TRY
    EXEC Production.usp_RestockLowStock
        @LowStockThreshold = 50,
        @TargetQty = 40;  -- invalid: target <= threshold
    PRINT N'FAIL T04: expected THROW for invalid params';
    SET @Failed += 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 53010
        PRINT N'PASS T04: invalid params rejected';
    ELSE
    BEGIN
        PRINT CONCAT(N'FAIL T04: unexpected error — ', ERROR_MESSAGE());
        SET @Failed += 1;
    END
END CATCH;

IF (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854) <> @QtyBefore
BEGIN
    PRINT N'FAIL T04: quantity changed on invalid call';
    SET @Failed += 1;
END

/* Summary */
IF @Failed = 0
    PRINT N'ALL ACCEPTANCE TESTS PASSED';
ELSE
    PRINT CONCAT(N'FAILED COUNT = ', @Failed);
GO
