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

DELETE dbo.StateProvince
WHERE StateProvinceID NOT IN (
    SELECT TOP 1 WITH TIES
        StateProvinceID
    FROM dbo.StateProvince
    ORDER BY ROW_NUMBER() OVER (PARTITION BY AddressType
                                ORDER BY StateProvinceID DESC)
);

DECLARE @ConstraintName NVARCHAR(50);

DECLARE ConstraintsCursor CURSOR FOR
SELECT
    CONSTRAINT_NAME
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'StateProvince'
UNION
SELECT
    dc.name
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON c.column_id = dc.parent_column_id
WHERE dc.parent_object_id = OBJECT_ID(N'dbo.StateProvince');

OPEN ConstraintsCursor;

FETCH NEXT FROM ConstraintsCursor
INTO @ConstraintName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('ALTER TABLE dbo.StateProvince
          DROP CONSTRAINT ' + @ConstraintName);

    FETCH NEXT FROM ConstraintsCursor
    INTO @ConstraintName;
END;

CLOSE ConstraintsCursor;
DEALLOCATE ConstraintsCursor;

DROP TABLE dbo.StateProvince;
