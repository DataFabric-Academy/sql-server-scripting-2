CREATE TRIGGER [Sales].[trg_MiniOrders_InsteadOfDelete]
ON [Sales].[MiniOrders]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET
        o.[Status] = 'Cancelled',
        o.[LastModifiedUtc] = SYSUTCDATETIME(),
        o.[ModifiedBy] = SUSER_SNAME()
    FROM [Sales].[MiniOrders] AS o
    INNER JOIN deleted AS d
        ON d.[OrderID] = o.[OrderID];
END;
GO
