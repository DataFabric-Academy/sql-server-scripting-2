CREATE FUNCTION [Sales].[ufn_GetCustomerOrderSummary]
(
    @CustID int
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.[OrderID],
        o.[OrderDate],
        o.[Status],
        LineCount = COUNT(d.[ProductID]),
        MerchandiseTotal = SUM(d.[UnitPrice] * d.[Quantity] * (1 - d.[Discount])),
        o.[Freight]
    FROM [Sales].[MiniOrders] AS o
    LEFT JOIN [Sales].[MiniOrderDetails] AS d
        ON d.[OrderID] = o.[OrderID]
    WHERE o.[CustID] = @CustID
    GROUP BY o.[OrderID], o.[OrderDate], o.[Status], o.[Freight]
);
GO
