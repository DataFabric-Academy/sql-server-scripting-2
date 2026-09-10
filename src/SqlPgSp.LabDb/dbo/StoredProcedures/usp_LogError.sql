CREATE PROCEDURE [dbo].[usp_LogError]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[ErrorLog]
    (
        [UserName],
        [ErrorNumber],
        [ErrorSeverity],
        [ErrorState],
        [ErrorProcedure],
        [ErrorLine],
        [ErrorMessage],
        [XactState]
    )
    VALUES
    (
        SUSER_SNAME(),
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        XACT_STATE()
    );
END;
GO
