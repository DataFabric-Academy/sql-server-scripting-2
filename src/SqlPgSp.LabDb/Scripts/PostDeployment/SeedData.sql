/* Seed MiniProducts */
IF NOT EXISTS (SELECT 1 FROM [Production].[MiniProducts] WHERE [ProductID] = 854)
    INSERT INTO [Production].[MiniProducts] ([ProductID], [ProductName], [Quantity])
    VALUES (854, N'Lab Product 854', 50);

IF NOT EXISTS (SELECT 1 FROM [Production].[MiniProducts] WHERE [ProductID] = 859)
    INSERT INTO [Production].[MiniProducts] ([ProductID], [ProductName], [Quantity])
    VALUES (859, N'Lab Product 859', 40);

IF NOT EXISTS (SELECT 1 FROM [Production].[MiniProducts] WHERE [ProductID] = 860)
    INSERT INTO [Production].[MiniProducts] ([ProductID], [ProductName], [Quantity])
    VALUES (860, N'Lab Product 860', 30);

/* Seed MiniCustomers (fixed IDs for lab scripts) */
SET IDENTITY_INSERT [Sales].[MiniCustomers] ON;

IF NOT EXISTS (SELECT 1 FROM [Sales].[MiniCustomers] WHERE [CustID] = 1)
    INSERT INTO [Sales].[MiniCustomers]
    ([CustID], [CompanyName], [ContactName], [ContactTitle], [Address], [City], [Region], [PostalCode], [Country], [Phone])
    VALUES (1, N'Contoso Ltd', N'Anya', N'Buyer', N'1 Main St', N'Bangkok', NULL, N'10110', N'Thailand', N'02-000-0001');

IF NOT EXISTS (SELECT 1 FROM [Sales].[MiniCustomers] WHERE [CustID] = 2)
    INSERT INTO [Sales].[MiniCustomers]
    ([CustID], [CompanyName], [ContactName], [ContactTitle], [Address], [City], [Region], [PostalCode], [Country], [Phone])
    VALUES (2, N'Fabrikam Inc', N'Boon', N'Manager', N'2 River Rd', N'Chiang Mai', NULL, N'50000', N'Thailand', N'053-000-0002');

IF NOT EXISTS (SELECT 1 FROM [Sales].[MiniCustomers] WHERE [CustID] = 3)
    INSERT INTO [Sales].[MiniCustomers]
    ([CustID], [CompanyName], [ContactName], [ContactTitle], [Address], [City], [Region], [PostalCode], [Country], [Phone])
    VALUES (3, N'Northwind Traders', N'Chai', N'Owner', N'3 Lake Ave', N'Phuket', NULL, N'83000', N'Thailand', N'076-000-0003');

SET IDENTITY_INSERT [Sales].[MiniCustomers] OFF;
GO
