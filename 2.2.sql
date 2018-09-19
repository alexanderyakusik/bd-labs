USE AdventureWorks2012;
GO

CREATE TABLE dbo.StateProvince (
	StateProvinceID		    INT			 NOT NULL,
	StateProvinceCode       NCHAR(3)	 NOT NULL,
	CountryRegionCode       NVARCHAR(3)  NOT NULL,
	IsOnlyStateProvinceFlag BIT			 NOT NULL,
	Name					NVARCHAR(50) NOT NULL,
	TerritoryID				INT			 NOT NULL,
	ModifiedDate			DATETIME	 NOT NULL
);
GO

ALTER TABLE dbo.StateProvince
ADD PRIMARY KEY (StateProvinceID, StateProvinceCode);

ALTER TABLE dbo.StateProvince
ADD CHECK (TerritoryID % 2 = 0);

ALTER TABLE dbo.StateProvince
ADD DEFAULT 2 FOR TerritoryID;
GO
