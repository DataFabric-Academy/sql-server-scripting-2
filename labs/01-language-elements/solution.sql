/*
================================================================================
  Lab 01 — solution.sql
  เฉลยตรงกับ exercise.sql
================================================================================
*/

USE AdventureWorks;
GO

SET NOCOUNT ON;
GO

/*------------------------------------------------------------------------------
  TODO 1 — Variables & Expressions
------------------------------------------------------------------------------*/
DECLARE @ProductID   INT = 854;
DECLARE @Qty         INT = 12;
DECLARE @DiscountPct DECIMAL(4,3) = 0.15;
DECLARE @ListPrice   MONEY;
DECLARE @ProductName NVARCHAR(50);
DECLARE @LineTotal   MONEY;

SELECT
    @ProductName = MP.ProductName,
    @ListPrice   = P.ListPrice
FROM Production.MiniProducts AS MP
INNER JOIN Production.Product AS P
    ON P.ProductID = MP.ProductID
WHERE MP.ProductID = @ProductID;

SET @LineTotal = @ListPrice * @Qty * (1 - @DiscountPct);

SELECT
    @ProductID   AS ProductID,
    @ProductName AS ProductName,
    @ListPrice   AS ListPrice,
    @Qty         AS Qty,
    @DiscountPct AS DiscountPct,
    @LineTotal   AS LineTotal;
GO

/*------------------------------------------------------------------------------
  TODO 2 — IF / ELSE + IS NULL
------------------------------------------------------------------------------*/
DECLARE @NullMiddleCount INT =
(
    SELECT COUNT(*)
    FROM Person.Person
    WHERE MiddleName IS NULL
);

IF @NullMiddleCount > 0
    PRINT CONCAT(N'พบบุคคลที่ไม่มี MiddleName จำนวน ', @NullMiddleCount, N' คน');
ELSE
    PRINT N'ไม่พบบุคคลที่ MiddleName เป็น NULL';
GO

/*------------------------------------------------------------------------------
  TODO 3 — WHILE + CONTINUE + BREAK
------------------------------------------------------------------------------*/
DECLARE @Pid INT = 854;
DECLARE @QtyCheck INT;
DECLARE @PName NVARCHAR(50);

WHILE @Pid <= 870
BEGIN
    IF NOT EXISTS
    (
        SELECT 1 FROM Production.MiniProducts WHERE ProductID = @Pid
    )
    BEGIN
        SET @Pid += 1;
        CONTINUE;
    END

    SELECT @PName = ProductName, @QtyCheck = Quantity
    FROM Production.MiniProducts
    WHERE ProductID = @Pid;

    PRINT CONCAT(N'ProductID=', @Pid, N' Name=', @PName, N' Qty=', @QtyCheck);

    IF @QtyCheck < 20
        BREAK;

    SET @Pid += 1;
END
GO

/*------------------------------------------------------------------------------
  TODO 4.1 — Table variable
------------------------------------------------------------------------------*/
DECLARE @Cats TABLE
(
    ProductCategoryID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

INSERT INTO @Cats (ProductCategoryID, Name)
SELECT ProductCategoryID, Name
FROM Production.ProductCategory;

SELECT COUNT(*) AS CatCount_TableVar FROM @Cats;
GO

/*------------------------------------------------------------------------------
  TODO 4.2 — Temp table
------------------------------------------------------------------------------*/
IF OBJECT_ID(N'tempdb..#Cats') IS NOT NULL DROP TABLE #Cats;

CREATE TABLE #Cats
(
    ProductCategoryID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

INSERT INTO #Cats (ProductCategoryID, Name)
SELECT ProductCategoryID, Name
FROM Production.ProductCategory;

SELECT COUNT(*) AS CatCount_TempTable FROM #Cats;

DROP TABLE #Cats;
GO

PRINT N'===== Lab 01 solution ครบ =====';
GO
