USE AdventureWorks2012;
GO

CREATE PROCEDURE dbo.uspProductsOffersByCategories
    @Categories NVARCHAR(MAX)
AS
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
    SELECT
      *
    FROM (
      SELECT
        pr.Name,
        so.Category,
        so.DiscountPct
      FROM sales.SpecialOffer so
      INNER JOIN sales.SpecialOfferProduct sop ON sop.SpecialOfferID = so.SpecialOfferID
      INNER JOIN Production.Product pr         ON pr.ProductID       = sop.ProductID
    ) AS Source
    PIVOT (
      MAX(DiscountPct)
      FOR category
      IN (' + @Categories + ')
    ) Result;';

    EXECUTE sp_executesql @sql;
GO

EXECUTE dbo.uspProductsOffersByCategories '[Reseller],[No Discount],[Customer]';
