CREATE TABLE [Sales].[MiniOrders]
(
    [OrderID]             int IDENTITY(1, 1) NOT NULL,
    [CustID]              int NULL,
    [PurchaseOrderNumber] varchar(25) NULL,
    [OrderDate]           datetime NOT NULL
        CONSTRAINT [DFT_MiniOrders_OrderDate] DEFAULT (SYSUTCDATETIME()),
    [Freight]             money NOT NULL
        CONSTRAINT [DFT_MiniOrders_Freight] DEFAULT ((0)),
    [Status]              varchar(20) NOT NULL
        CONSTRAINT [DFT_MiniOrders_Status] DEFAULT ('Open'),
    [LastModifiedUtc]     datetime2(0) NULL,
    [ModifiedBy]          sysname NULL,
    CONSTRAINT [PK_MiniOrders] PRIMARY KEY CLUSTERED ([OrderID]),
    CONSTRAINT [FK_MiniOrders_MiniCustomers]
        FOREIGN KEY ([CustID]) REFERENCES [Sales].[MiniCustomers] ([CustID])
);
GO
