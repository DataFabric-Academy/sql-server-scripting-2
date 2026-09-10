CREATE TABLE [Production].[MiniProducts]
(
    [ProductID]   int NOT NULL,
    [ProductName] nvarchar(50) NOT NULL,
    [Quantity]    int NOT NULL,
    CONSTRAINT [PK_MiniProducts] PRIMARY KEY CLUSTERED ([ProductID]),
    CONSTRAINT [CK_MiniProducts_StockCount] CHECK ([Quantity] >= 0)
);
GO
