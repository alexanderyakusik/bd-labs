USE AdventureWorks2012;
GO

CREATE TABLE Sales.SpecialOfferHst (
    ID           INT           NOT NULL IDENTITY(1, 1),
    Action       NCHAR(6)      NOT NULL,
    ModifiedDate DATETIME      NOT NULL DEFAULT GETDATE(),
    SourceID     INT           NOT NULL,
    UserName     NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    PRIMARY KEY (ID)
);
GO

CREATE TRIGGER SpecialOffer_INSERT
ON Sales.SpecialOffer
AFTER INSERT
AS
INSERT INTO Sales.SpecialOfferHst (Action, SourceID)
SELECT 'INSERT', SpecialOfferID
FROM inserted;
GO

CREATE TRIGGER SpecialOffer_UPDATE
ON Sales.SpecialOffer
AFTER UPDATE
AS
INSERT INTO Sales.SpecialOfferHst (Action, SourceID)
SELECT 'UPDATE', SpecialOfferID
FROM inserted;
GO

CREATE TRIGGER SpecialOffer_DELETE
ON Sales.SpecialOffer
AFTER DELETE
AS
INSERT INTO Sales.SpecialOfferHst (Action, SourceID)
SELECT 'DELETE', SpecialOfferID
FROM deleted;
GO

CREATE VIEW SpecialOffers
WITH ENCRYPTION
AS
SELECT * FROM Sales.SpecialOffer;
GO

DECLARE @InsertedId INT;

INSERT INTO SpecialOffers (Description, Type, Category, StartDate, EndDate)
VALUES ('test', 'test', 'test', GETDATE(), GETDATE());

SET @InsertedId = SCOPE_IDENTITY();

UPDATE SpecialOffers
SET Description = 'test1'
WHERE SpecialOfferID = @InsertedId;

DELETE FROM SpecialOffers
WHERE SpecialOfferID = @InsertedId;
