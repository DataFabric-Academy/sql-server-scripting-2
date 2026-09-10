CREATE TABLE [Sales].[MiniCustomers]
(
    [CustID]       int IDENTITY(1, 1) NOT NULL,
    [CompanyName]  nvarchar(40) NOT NULL,
    [ContactName]  nvarchar(30) NOT NULL,
    [ContactTitle] nvarchar(30) NOT NULL,
    [Address]      nvarchar(60) NOT NULL,
    [City]         nvarchar(15) NOT NULL,
    [Region]       nvarchar(15) NULL,
    [PostalCode]   nvarchar(10) NULL,
    [Country]      nvarchar(15) NOT NULL,
    [Phone]        nvarchar(24) NOT NULL,
    [IsActive]     bit NOT NULL
        CONSTRAINT [DFT_MiniCustomers_IsActive] DEFAULT (1),
    CONSTRAINT [PK_MiniCustomers] PRIMARY KEY CLUSTERED ([CustID])
);
GO
