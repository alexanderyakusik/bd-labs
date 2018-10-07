USE AdventureWorks2012;
GO

CREATE FUNCTION GetSpecialOfferStartDate (@SpecialOfferID INT)
RETURNS NVARCHAR(30)
AS
BEGIN
    RETURN (
        SELECT TOP 1
            DATENAME(m, StartDate)
            + ', '
            + CAST(DATEPART(dw, StartDate) AS NVARCHAR(2))
            + '. '
            + DATENAME(dw, StartDate)
        FROM Sales.SpecialOffer
        WHERE SpecialOfferID = @SpecialOfferID
    );
END;
GO

CREATE FUNCTION GetSpecialOfferProducts (@SpecialOfferID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        pr.ProductID,
        pr.Name
    FROM Sales.SpecialOffer so
    INNER JOIN Sales.SpecialOfferProduct sop ON sop.SpecialOfferID = so.SpecialOfferID
    INNER JOIN Production.Product pr         ON pr.ProductID = sop.ProductID
    WHERE so.SpecialOfferID = @SpecialOfferID
);
GO

SELECT
    so.SpecialOfferID,
    pr.ProductID,
    pr.Name
FROM Sales.SpecialOffer so
CROSS APPLY dbo.GetSpecialOfferProducts(so.SpecialOfferID) pr
ORDER BY so.SpecialOfferID;

SELECT
    so.SpecialOfferID,
    pr.ProductID,
    pr.Name
FROM Sales.SpecialOffer so
OUTER APPLY dbo.GetSpecialOfferProducts(so.SpecialOfferID) pr
ORDER BY so.SpecialOfferID;
GO

DROP FUNCTION dbo.GetSpecialOfferProducts;
GO

CREATE FUNCTION dbo.GetSpecialOfferProducts (@SpecialOfferID INT)
RETURNS @SpecialOfferProducts TABLE (
    ProductID INT,
    Name      NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @SpecialOfferProducts
    SELECT
        pr.ProductID,
        pr.Name
    FROM Sales.SpecialOffer so
    INNER JOIN Sales.SpecialOfferProduct sop ON sop.SpecialOfferID = so.SpecialOfferID
    INNER JOIN Production.Product pr         ON pr.ProductID = sop.ProductID
    WHERE so.SpecialOfferID = @SpecialOfferID;

    RETURN;
END;
GO
