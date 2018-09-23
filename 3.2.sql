USE AdventureWorks2012;
GO

ALTER TABLE dbo.StateProvince
ADD
    TaxRate      SMALLMONEY,
    CurrencyCode NCHAR(3),
    AverageRate  MONEY,
    IntTaxRate   AS CEILING(TaxRate);

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
    AverageRate             MONEY        NULL,
    PRIMARY KEY (StateProvinceID)
);
