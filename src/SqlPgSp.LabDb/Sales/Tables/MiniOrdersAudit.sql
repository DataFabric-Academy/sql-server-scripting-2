CREATE TABLE [Sales].[MiniOrdersAudit]
(
    [AuditID]     int IDENTITY(1, 1) NOT NULL,
    [AuditUtc]    datetime2(0) NOT NULL
        CONSTRAINT [DFT_MiniOrdersAudit_AuditUtc] DEFAULT (SYSUTCDATETIME()),
    [AuditAction] char(1) NOT NULL,
    [OrderID]     int NOT NULL,
    [CustID]      int NULL,
    [Status]      varchar(20) NULL,
    [ModifiedBy]  sysname NULL,
    CONSTRAINT [PK_MiniOrdersAudit] PRIMARY KEY CLUSTERED ([AuditID])
);
GO
