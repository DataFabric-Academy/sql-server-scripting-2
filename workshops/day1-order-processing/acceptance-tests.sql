/*
==============================================================================
 Workshop Day 1 — acceptance-tests.sql
 รันหลัง implement solution / ของผู้เรียน
 ผลลัพธ์: ตารางสรุป TestName / Passed (1=ผ่าน, 0=ไม่ผ่าน)
==============================================================================
*/
USE AdventureWorks;
GO

SET NOCOUNT ON;

/* รีเซ็ตสต็อกให้ทดสอบซ้ำได้ */
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID WHEN 854 THEN 50 WHEN 859 THEN 40 WHEN 860 THEN 30 END
WHERE ProductID IN (854, 859, 860);

DECLARE @Results TABLE
(
    TestName nvarchar(100) NOT NULL,
    Passed   bit NOT NULL,
    Detail   nvarchar(400) NULL
);

DECLARE @oid int, @err int, @msg nvarchar(4000);
DECLARE @qtyBefore int, @qtyAfter int, @errBefore int, @errAfter int;
DECLARE @orderCountBefore int, @orderCountAfter int;

/* ---------- T01: PlaceOrder สำเร็จ ---------- */
SET @oid = NULL;
SET @err = NULL;
SET @qtyBefore = (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854);

BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = 1, @ProductID = 854, @Quantity = 2, @UnitPrice = 100.00,
        @OrderID = @oid OUTPUT;
END TRY
BEGIN CATCH
    SET @err = ERROR_NUMBER();
    SET @msg = ERROR_MESSAGE();
END CATCH;

SET @qtyAfter = (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 854);

INSERT INTO @Results (TestName, Passed, Detail)
VALUES
(
    N'T01_PlaceOrder_Success',
    CASE WHEN @err IS NULL AND @oid IS NOT NULL AND @qtyAfter = @qtyBefore - 2 THEN 1 ELSE 0 END,
    CONCAT(N'OrderID=', COALESCE(CONVERT(varchar(20), @oid), N'NULL'),
           N'; Err=', COALESCE(CONVERT(varchar(20), @err), N'NULL'),
           N'; Qty ', @qtyBefore, N'->', @qtyAfter)
);

/* ---------- T02: ลูกค้าไม่ถูกต้อง ---------- */
SET @oid = NULL;
SET @err = NULL;
BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = -1, @ProductID = 854, @Quantity = 1, @UnitPrice = 10,
        @OrderID = @oid OUTPUT;
END TRY
BEGIN CATCH
    SET @err = ERROR_NUMBER();
END CATCH;

INSERT INTO @Results (TestName, Passed, Detail)
VALUES
(
    N'T02_BadCustomer_Throws51001',
    CASE WHEN @err = 51001 AND @oid IS NULL THEN 1 ELSE 0 END,
    CONCAT(N'Err=', COALESCE(CONVERT(varchar(20), @err), N'NULL'))
);

/* ---------- T03: สต็อกไม่พอ — ไม่เหลือ orphan order ---------- */
SET @oid = NULL;
SET @err = NULL;
SET @qtyBefore = (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 860);
SET @orderCountBefore = (SELECT COUNT(*) FROM Sales.MiniOrders);
SET @errBefore = (SELECT COUNT(*) FROM dbo.ErrorLog);

BEGIN TRY
    EXEC Sales.usp_PlaceOrder
        @CustID = 1, @ProductID = 860, @Quantity = 9999, @UnitPrice = 1,
        @OrderID = @oid OUTPUT;
END TRY
BEGIN CATCH
    SET @err = ERROR_NUMBER();
END CATCH;

SET @qtyAfter = (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 860);
SET @orderCountAfter = (SELECT COUNT(*) FROM Sales.MiniOrders);
SET @errAfter = (SELECT COUNT(*) FROM dbo.ErrorLog);

INSERT INTO @Results (TestName, Passed, Detail)
VALUES
(
    N'T03_Oversell_NoPartial_And_Logged',
    CASE
        WHEN @err = 51002
         AND @qtyAfter = @qtyBefore
         AND @orderCountAfter = @orderCountBefore
         AND @errAfter > @errBefore
        THEN 1 ELSE 0
    END,
    CONCAT(N'Err=', COALESCE(CONVERT(varchar(20), @err), N'NULL'),
           N'; Qty same=', CASE WHEN @qtyAfter = @qtyBefore THEN 1 ELSE 0 END,
           N'; Orders same=', CASE WHEN @orderCountAfter = @orderCountBefore THEN 1 ELSE 0 END,
           N'; ErrorLog+', @errAfter - @errBefore)
);

/* ---------- T04: PlaceOrderLines (TVP) สำเร็จ ---------- */
IF OBJECT_ID(N'Sales.usp_PlaceOrderLines', N'P') IS NULL OR TYPE_ID(N'Sales.OrderLineType') IS NULL
BEGIN
    INSERT INTO @Results (TestName, Passed, Detail)
    VALUES (N'T04_PlaceOrderLines_TVP_Success', 0, N'Missing Sales.OrderLineType or usp_PlaceOrderLines');
END
ELSE
BEGIN
    SET @oid = NULL;
    SET @err = NULL;
    SET @qtyBefore = (SELECT Quantity FROM Production.MiniProducts WHERE ProductID = 859);

    DECLARE @lines Sales.OrderLineType;
    INSERT INTO @lines (ProductID, Quantity, UnitPrice, Discount)
    VALUES (859, 2, 50.00, 0), (860, 1, 19.00, 0);

    BEGIN TRY
        EXEC Sales.usp_PlaceOrderLines
            @CustID = 2,
            @Lines = @lines,
            @Freight = 5,
            @OrderID = @oid OUTPUT;
    END TRY
    BEGIN CATCH
        SET @err = ERROR_NUMBER();
        SET @msg = ERROR_MESSAGE();
    END CATCH;

    DECLARE @lineCnt int =
    (
        SELECT COUNT(*) FROM Sales.MiniOrderDetails WHERE OrderID = @oid
    );

    INSERT INTO @Results (TestName, Passed, Detail)
    VALUES
    (
        N'T04_PlaceOrderLines_TVP_Success',
        CASE WHEN @err IS NULL AND @oid IS NOT NULL AND @lineCnt = 2 THEN 1 ELSE 0 END,
        CONCAT(N'OrderID=', COALESCE(CONVERT(varchar(20), @oid), N'NULL'),
               N'; Lines=', COALESCE(CONVERT(varchar(20), @lineCnt), N'0'),
               N'; Err=', COALESCE(CONVERT(varchar(20), @err), N'NULL'),
               N' ', COALESCE(@msg, N''))
    );
END

/* ---------- สรุป ---------- */
SELECT TestName, Passed, Detail
FROM @Results
ORDER BY TestName;

SELECT
    SUM(CASE WHEN Passed = 1 THEN 1 ELSE 0 END) AS PassedCount,
    SUM(CASE WHEN Passed = 0 THEN 1 ELSE 0 END) AS FailedCount,
    COUNT(*) AS TotalTests
FROM @Results;

IF EXISTS (SELECT 1 FROM @Results WHERE Passed = 0)
    THROW 59999, N'Workshop Day 1 acceptance: FAILED — ดูตารางผลทดสอบ', 1;
ELSE
    PRINT N'Workshop Day 1 acceptance: ALL PASSED';
GO
