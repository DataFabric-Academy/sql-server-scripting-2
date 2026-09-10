CREATE TRIGGER [Sales].[trg_MiniOrders_Audit]
ON [Sales].[MiniOrders]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Sales].[MiniOrdersAudit] ([AuditAction], [OrderID], [CustID], [Status], [ModifiedBy])
    SELECT
        CASE WHEN d.[OrderID] IS NULL THEN 'I' ELSE 'U' END,
        i.[OrderID],
        i.[CustID],
        i.[Status],
        SUSER_SNAME()
    FROM inserted AS i
    LEFT JOIN deleted AS d
        ON d.[OrderID] = i.[OrderID];
END;
GO
