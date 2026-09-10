/*
==============================================================================
 Lab 07 — DML Triggers | Solutions
 Database: AdventureWorks / AdventureWorks2022
==============================================================================
*/
USE AdventureWorks;
GO

/* ==========================================================================
   Exercise 1
   ========================================================================== */
IF OBJECT_ID(N'Sales.MiniCustomersAudit', N'U') IS NOT NULL
    DROP TABLE Sales.MiniCustomersAudit;
GO

CREATE TABLE Sales.MiniCustomersAudit
(
    AuditID     int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    CustID      int NOT NULL,
    ActionUtc   datetime2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    Actor       sysname NOT NULL DEFAULT (ORIGINAL_LOGIN()),
    CompanyName nvarchar(40) NOT NULL
);
GO

CREATE OR ALTER TRIGGER Sales.trg_MiniCustomers_AfterInsert
ON Sales.MiniCustomers
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Sales.MiniCustomersAudit (CustID, CompanyName)
    SELECT i.CustID, i.CompanyName
    FROM inserted AS i;
END;
GO

INSERT INTO Sales.MiniCustomers
(
    CompanyName, ContactName, ContactTitle, Address, City, Country, Phone
)
VALUES
(N'Lab07 Co', N'Dee', N'Buyer', N'7 Lab Rd', N'Khon Kaen', N'Thailand', N'043-000-0007');

SELECT TOP (3) * FROM Sales.MiniCustomersAudit ORDER BY AuditID DESC;
GO

/* ==========================================================================
   Exercise 2
   ========================================================================== */
CREATE OR ALTER TRIGGER Production.trg_MiniProducts_QtyDecreaseWarn
ON Production.MiniProducts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Quantity)
    BEGIN
        INSERT INTO dbo.ErrorLog
        (
            UserName,
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            XactState
        )
        SELECT
            SUSER_SNAME(),
            50040,
            10,
            1,
            N'Production.trg_MiniProducts_QtyDecreaseWarn',
            NULL,
            N'Quantity decreased for ProductID='
                + CAST(i.ProductID AS nvarchar(20))
                + N' from '
                + CAST(d.Quantity AS nvarchar(20))
                + N' to '
                + CAST(i.Quantity AS nvarchar(20)),
            XACT_STATE()
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.ProductID = i.ProductID
        WHERE i.Quantity < d.Quantity;
    END
END;
GO

UPDATE Production.MiniProducts
SET Quantity = Quantity - 1
WHERE ProductID = 859;

SELECT TOP (3) *
FROM dbo.ErrorLog
WHERE ErrorNumber = 50040
ORDER BY ErrorLogID DESC;

-- คืนค่า
UPDATE Production.MiniProducts SET Quantity = Quantity + 1 WHERE ProductID = 859;
GO

/* ==========================================================================
   Exercise 3
   ========================================================================== */
CREATE OR ALTER TRIGGER Sales.trg_MiniCustomers_InsteadOfDelete
ON Sales.MiniCustomers
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
    SET c.IsActive = 0
    FROM Sales.MiniCustomers AS c
    INNER JOIN deleted AS d ON d.CustID = c.CustID;
END;
GO

DECLARE @id int =
(
    SELECT TOP (1) CustID
    FROM Sales.MiniCustomers
    WHERE CompanyName = N'Lab07 Co'
);

DELETE FROM Sales.MiniCustomers WHERE CustID = @id;

SELECT CustID, CompanyName, IsActive
FROM Sales.MiniCustomers
WHERE CustID = @id;
GO

/* ==========================================================================
   Exercise 4 — คำตอบสั้น
   ==========================================================================
   1) AFTER ทำงานหลัง DML สำเร็จ; INSTEAD OF แทนที่ DML (ใช้ soft-delete/view ได้)
   2) Nested = trigger โยง DML ไปตารางอื่นแล้วยิง trigger ของตารางนั้น
      Recursive = trigger บนตารางเดียวกันยิงตัวเอง (ต้องเปิด RECURSIVE_TRIGGERS)
   3) ไม่ควรใช้: เรียก API ภายนอกใน trigger; logic workflow ยาวที่ควรอยู่ใน service;
      หรือสิ่งที่ CHECK/FK ทำได้ชัดกว่า
*/
GO
