/*
==============================================================================
 SQL-PG-SP Lab Objects
 Database: AdventureWorks  (เปลี่ยนเป็น AdventureWorks2022 ได้ตามเครื่อง Lab)
 รันครั้งเดียวก่อนเริ่ม Day 1
==============================================================================
*/
USE AdventureWorks;
GO

/* --------------------------------------------------------------------------
   Production.MiniProducts — สต็อกสำหรับ demo Transaction / Workshop
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Production.MiniProducts', N'U') IS NOT NULL
    DROP TABLE Production.MiniProducts;
GO

SELECT
    P.ProductID,
    P.Name AS ProductName,
    SUM(ISNULL(I.Quantity, 0)) AS Quantity
INTO Production.MiniProducts
FROM Production.Product AS P
INNER JOIN Production.ProductInventory AS I
    ON P.ProductID = I.ProductID
GROUP BY P.ProductID, P.Name;
GO

ALTER TABLE Production.MiniProducts
ADD CONSTRAINT PK_MiniProducts PRIMARY KEY CLUSTERED (ProductID);
GO

ALTER TABLE Production.MiniProducts
ADD CONSTRAINT CK_MiniProducts_StockCount CHECK (Quantity >= 0);
GO

/* ให้ Product ที่ใช้ใน demo มีสต็อกเพียงพอ */
UPDATE Production.MiniProducts
SET Quantity = CASE ProductID
    WHEN 854 THEN 50
    WHEN 859 THEN 40
    WHEN 860 THEN 30
    ELSE Quantity
END
WHERE ProductID IN (854, 859, 860);
GO

/* --------------------------------------------------------------------------
   Sales.MiniCustomers / MiniOrders / MiniOrderDetails
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'Sales.MiniOrderDetails', N'U') IS NOT NULL
    DROP TABLE Sales.MiniOrderDetails;
IF OBJECT_ID(N'Sales.MiniOrders', N'U') IS NOT NULL
    DROP TABLE Sales.MiniOrders;
IF OBJECT_ID(N'Sales.MiniCustomers', N'U') IS NOT NULL
    DROP TABLE Sales.MiniCustomers;
GO

CREATE TABLE Sales.MiniCustomers
(
    CustID        int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_MiniCustomers PRIMARY KEY,
    CompanyName   nvarchar(40)  NOT NULL,
    ContactName   nvarchar(30)  NOT NULL,
    ContactTitle  nvarchar(30)  NOT NULL,
    Address       nvarchar(60)  NOT NULL,
    City          nvarchar(15)  NOT NULL,
    Region        nvarchar(15)  NULL,
    PostalCode    nvarchar(10)  NULL,
    Country       nvarchar(15)  NOT NULL,
    Phone         nvarchar(24)  NOT NULL,
    IsActive      bit           NOT NULL
        CONSTRAINT DFT_MiniCustomers_IsActive DEFAULT (1)
);
GO

CREATE TABLE Sales.MiniOrders
(
    OrderID             int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_MiniOrders PRIMARY KEY CLUSTERED,
    CustID              int NULL
        CONSTRAINT FK_MiniOrders_MiniCustomers
        FOREIGN KEY (CustID) REFERENCES Sales.MiniCustomers (CustID),
    PurchaseOrderNumber varchar(25) NULL,
    OrderDate           datetime NOT NULL
        CONSTRAINT DFT_MiniOrders_OrderDate DEFAULT (SYSUTCDATETIME()),
    Freight             money NOT NULL
        CONSTRAINT DFT_MiniOrders_Freight DEFAULT (0),
    Status              varchar(20) NOT NULL
        CONSTRAINT DFT_MiniOrders_Status DEFAULT ('Open'),
    LastModifiedUtc     datetime2(0) NULL,
    ModifiedBy          sysname NULL
);
GO

CREATE TABLE Sales.MiniOrderDetails
(
    OrderID   int NOT NULL
        CONSTRAINT FK_MiniOrderDetails_Orders
        FOREIGN KEY (OrderID) REFERENCES Sales.MiniOrders (OrderID),
    ProductID int NOT NULL
        CONSTRAINT FK_MiniOrderDetails_Products
        FOREIGN KEY (ProductID) REFERENCES Production.MiniProducts (ProductID),
    UnitPrice money NOT NULL
        CONSTRAINT DFT_MiniOrderDetails_UnitPrice DEFAULT (0),
    Quantity  smallint NOT NULL
        CONSTRAINT DFT_MiniOrderDetails_Quantity DEFAULT (1),
    Discount  numeric(4, 3) NOT NULL
        CONSTRAINT DFT_MiniOrderDetails_Discount DEFAULT (0),
    CONSTRAINT PK_MiniOrderDetails PRIMARY KEY CLUSTERED (OrderID, ProductID)
);
GO

/* Seed ลูกค้าตัวอย่าง */
SET IDENTITY_INSERT Sales.MiniCustomers ON;
INSERT INTO Sales.MiniCustomers
(
    CustID, CompanyName, ContactName, ContactTitle,
    Address, City, Region, PostalCode, Country, Phone
)
VALUES
(1, N'Contoso Ltd', N'Anya', N'Buyer', N'1 Main St', N'Bangkok', NULL, N'10110', N'Thailand', N'02-000-0001'),
(2, N'Fabrikam Inc', N'Boon', N'Manager', N'2 River Rd', N'Chiang Mai', NULL, N'50000', N'Thailand', N'053-000-0002'),
(3, N'Northwind Traders', N'Chai', N'Owner', N'3 Lake Ave', N'Phuket', NULL, N'83000', N'Thailand', N'076-000-0003');
SET IDENTITY_INSERT Sales.MiniCustomers OFF;
GO

/* --------------------------------------------------------------------------
   dbo.ErrorLog — ใช้กับ Stored Procedure / Workshop
   -------------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.ErrorLog', N'U') IS NOT NULL
    DROP TABLE dbo.ErrorLog;
GO

CREATE TABLE dbo.ErrorLog
(
    ErrorLogID     int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_ErrorLog PRIMARY KEY CLUSTERED,
    ErrorTime      datetime2(3) NOT NULL
        CONSTRAINT DFT_ErrorLog_ErrorTime DEFAULT (SYSUTCDATETIME()),
    UserName       sysname NOT NULL
        CONSTRAINT DFT_ErrorLog_UserName DEFAULT (SUSER_SNAME()),
    ErrorNumber    int NULL,
    ErrorSeverity  int NULL,
    ErrorState     int NULL,
    ErrorProcedure nvarchar(128) NULL,
    ErrorLine      int NULL,
    ErrorMessage   nvarchar(4000) NULL,
    XactState      smallint NULL
);
GO

PRINT N'Lab objects created successfully.';
SELECT
    (SELECT COUNT(*) FROM Production.MiniProducts) AS MiniProducts,
    (SELECT COUNT(*) FROM Sales.MiniCustomers) AS MiniCustomers,
    OBJECT_ID(N'dbo.ErrorLog', N'U') AS ErrorLogObjectId;
GO
