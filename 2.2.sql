USE AdventureWorks2012;
GO

CREATE TABLE dbo.StateProvince (
    StateProvinceID         INT          NOT NULL,
    StateProvinceCode       NCHAR(3)     NOT NULL,
    CountryRegionCode       NVARCHAR(3)  NOT NULL,
    IsOnlyStateProvinceFlag BIT          NOT NULL,
    Name                    NVARCHAR(50) NOT NULL,
    TerritoryID             INT          NOT NULL,
    ModifiedDate            DATETIME     NOT NULL
);
GO

ALTER TABLE dbo.StateProvince
ADD PRIMARY KEY (StateProvinceID, StateProvinceCode);

ALTER TABLE dbo.StateProvince
ADD CHECK (TerritoryID % 2 = 0);

ALTER TABLE dbo.StateProvince
ADD DEFAULT 2 FOR TerritoryID;
GO

INSERT INTO dbo.StateProvince (
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    ModifiedDate)
SELECT TOP(1) WITH TIES
    stpr.StateProvinceID,
    stpr.StateProvinceCode,
    stpr.CountryRegionCode,
    stpr.IsOnlyStateProvinceFlag,
    stpr.Name,
    stpr.ModifiedDate
FROM Person.StateProvince stpr
INNER JOIN Person.Address addr                 ON addr.StateProvinceID = stpr.StateProvinceID
INNER JOIN Person.BusinessEntityAddress beaddr ON beaddr.AddressID = addr.AddressID
INNER JOIN Person.AddressType addrtp           ON addrtp.AddressTypeID = beaddr.AddressTypeID
WHERE addrtp.Name = 'Shipping'
ORDER BY ROW_NUMBER() OVER (PARTITION BY stpr.StateProvinceID, stpr.StateProvinceCode
                            ORDER BY addr.AddressID DESC);

ALTER TABLE dbo.StateProvince
ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT NULL;
