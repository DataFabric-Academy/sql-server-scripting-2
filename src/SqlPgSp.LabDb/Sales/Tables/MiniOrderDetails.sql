CREATE TABLE [Sales].[MiniOrderDetails]
(
    [OrderID]   int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitPrice] money NOT NULL
        CONSTRAINT [DFT_MiniOrderDetails_UnitPrice] DEFAULT ((0)),
    [Quantity]  smallint NOT NULL
        CONSTRAINT [DFT_MiniOrderDetails_Quantity] DEFAULT ((1)),
    [Discount]  numeric(4, 3) NOT NULL
        CONSTRAINT [DFT_MiniOrderDetails_Discount] DEFAULT ((0)),
    CONSTRAINT [PK_MiniOrderDetails] PRIMARY KEY CLUSTERED ([OrderID], [ProductID]),
    CONSTRAINT [FK_MiniOrderDetails_Orders]
        FOREIGN KEY ([OrderID]) REFERENCES [Sales].[MiniOrders] ([OrderID]),
    CONSTRAINT [FK_MiniOrderDetails_Products]
        FOREIGN KEY ([ProductID]) REFERENCES [Production].[MiniProducts] ([ProductID])
);
GO
