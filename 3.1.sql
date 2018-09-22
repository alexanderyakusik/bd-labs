USE AdventureWorks2012;
GO

ALTER TABLE dbo.StateProvince
ADD AddressType NVARCHAR(50);
GO

DECLARE @StateProvince TABLE
(
    StateProvinceID         INT          NOT NULL,
    StateProvinceCode       NCHAR(3)     NOT NULL,
    CountryRegionCode       NVARCHAR(3)  NOT NULL,
    IsOnlyStateProvinceFlag SMALLINT     NULL,
    Name                    NVARCHAR(50) NOT NULL,
    TerritoryID             INT          NOT NULL
        DEFAULT 2
        CHECK (TerritoryID % 2 = 0),
    ModifiedDate            DATETIME     NOT NULL,
    AddressType             NVARCHAR(50) NULL,
    PRIMARY KEY (StateProvinceID, StateProvinceCode)
);

INSERT INTO @StateProvince
SELECT * FROM dbo.StateProvince;

DECLARE @AddressTypesCount INT;
SELECT @AddressTypesCount = COUNT(*) FROM Person.AddressType;

UPDATE @StateProvince
SET
    AddressType = (
        SELECT
            at.Name
        FROM Person.AddressType at
        WHERE at.AddressTypeID = (ABS(CHECKSUM(NewId())) % @AddressTypesCount) + 1
    );

UPDATE dest
SET
    dest.AddressType = src.AddressType,
    dest.Name = cr.Name + ' ' + dest.Name
FROM
    dbo.StateProvince dest
    INNER JOIN @StateProvince src      ON src.StateProvinceID = dest.StateProvinceID
    INNER JOIN Person.CountryRegion cr ON cr.CountryRegionCode = src.CountryRegionCode;
