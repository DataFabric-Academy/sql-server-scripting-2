CREATE TABLE [dbo].[ErrorLog]
(
    [ErrorLogID]     int IDENTITY(1, 1) NOT NULL,
    [ErrorTime]      datetime2(3) NOT NULL
        CONSTRAINT [DFT_ErrorLog_ErrorTime] DEFAULT (SYSUTCDATETIME()),
    [UserName]       sysname NOT NULL
        CONSTRAINT [DFT_ErrorLog_UserName] DEFAULT (SUSER_SNAME()),
    [ErrorNumber]    int NULL,
    [ErrorSeverity]  int NULL,
    [ErrorState]     int NULL,
    [ErrorProcedure] nvarchar(128) NULL,
    [ErrorLine]      int NULL,
    [ErrorMessage]   nvarchar(4000) NULL,
    [XactState]      smallint NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogID])
);
GO
