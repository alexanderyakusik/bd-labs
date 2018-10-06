USE AdventureWorks2012;
GO

ALTER TABLE dbo.StateProvince
ADD
    TaxRate      SMALLMONEY,
    CurrencyCode NCHAR(3),
    AverageRate  MONEY,
    IntTaxRate   AS CEILING(TaxRate);
GO

CREATE TABLE #StateProvince (
    StateProvinceID         INT          NOT NULL,
    StateProvinceCode       NCHAR(3)     NOT NULL,
    CountryRegionCode       NVARCHAR(3)  NOT NULL,
    IsOnlyStateProvinceFlag SMALLINT     NULL,
    Name                    NVARCHAR(50) NOT NULL,
    TerritoryID             INT          NOT NULL,
    ModifiedDate            DATETIME     NOT NULL,
    TaxRate                 SMALLMONEY   NULL,
    CurrencyCode            NCHAR(3)     NULL,
    AverageRate             MONEY        NULL
    PRIMARY KEY (StateProvinceID)
);

INSERT INTO #StateProvince
SELECT
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    TerritoryID,
    ModifiedDate,
    TaxRate,
    CurrencyCode,
    AverageRate
FROM dbo.StateProvince;

UPDATE dest
SET
    dest.CurrencyCode = src.CurrencyCode
FROM #StateProvince AS dest
INNER JOIN (
    SELECT
        CurrencyCode,
        ROW_NUMBER() OVER (ORDER BY CurrencyCode ASC) AS RowNumber
    FROM Sales.Currency
) src ON src.RowNumber = dest.StateProvinceID;

UPDATE dest
SET
    dest.TaxRate = tr.TaxRate
FROM #StateProvince AS dest
INNER JOIN Sales.SalesTaxRate tr ON tr.StateProvinceID = dest.StateProvinceID
WHERE tr.TaxType = 1;

WITH CurrencyMaxRates(CurrencyCode, MaxRate) AS (
    SELECT
        ToCurrencyCode,
        MAX(AverageRate)
    FROM sales.CurrencyRate
    GROUP BY ToCurrencyCode)
    UPDATE dest
        SET dest.AverageRate = cmr.MaxRate
    FROM #StateProvince AS dest
    INNER JOIN CurrencyMaxRates cmr ON cmr.CurrencyCode = dest.CurrencyCode
    COLLATE SQL_Latin1_General_CP1_CI_AS

DELETE FROM dbo.StateProvince
WHERE CountryRegionCode = 'CA';

MERGE INTO dbo.StateProvince dest
USING #StateProvince src ON src.StateProvinceID = dest.StateProvinceID
WHEN MATCHED THEN
    UPDATE SET
        dest.TaxRate = src.TaxRate,
        dest.CurrencyCode = src.CurrencyCode,
        dest.AverageRate = src.AverageRate
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    VALUES (
        src.StateProvinceID,
        src.StateProvinceCode,
        src.CountryRegionCode,
        src.IsOnlyStateProvinceFlag,
        src.Name,
        src.TerritoryID,
        src.ModifiedDate,
        src.TaxRate,
        src.CurrencyCode,
        src.AverageRate
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
;
