USE AdventureWorks2012;
GO

CREATE VIEW ProductsSpecialOffers
WITH SCHEMABINDING
AS
SELECT
    sop.SpecialOfferID,
    sop.ProductID,
    pr.Name AS ProductName,
    so.Description,
    so.DiscountPct,
    so.Type,
    so.Category,
    so.StartDate,
    so.EndDate,
    so.MinQty,
    so.MaxQty
FROM Sales.SpecialOffer so
INNER JOIN Sales.SpecialOfferProduct sop ON sop.SpecialOfferID = so.SpecialOfferID
INNER JOIN Production.Product pr         ON pr.ProductID       = sop.ProductID; 
GO

CREATE UNIQUE CLUSTERED INDEX IDX_MAIN
    ON ProductsSpecialOffers (ProductID, SpecialOfferID);
GO

CREATE TRIGGER ProductsSpecialOffers_Manager
ON ProductsSpecialOffers
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action CHAR(1);
    SET @Action = (CASE
        WHEN EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)
            THEN 'U'
        WHEN EXISTS(SELECT * FROM INSERTED)
            THEN 'I'
        WHEN EXISTS(SELECT * FROM DELETED)
            THEN 'D'
    END);

    IF @Action = 'D'
    BEGIN
        DELETE FROM Sales.SpecialOfferProduct
        WHERE ProductID = (SELECT DISTINCT ProductID FROM deleted)
          AND SpecialOfferID IN (SELECT SpecialOfferID FROM deleted);

        DELETE FROM Sales.SpecialOffer
        WHERE SpecialOfferID IN (
            SELECT SpecialOfferID FROM deleted
            EXCEPT
            SELECT DISTINCT
                SpecialOfferID
            FROM Sales.SpecialOfferProduct
            WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted)
        );
    END;

    IF @Action = 'I'
    BEGIN
        DECLARE
            @SpecialOfferID INT,
            @ProductName    NVARCHAR(50),
            @Description    NVARCHAR(255),
            @DiscountPct    SMALLMONEY,
            @Type           NVARCHAR(50),
            @Category       NVARCHAR(50),
            @StartDate      DATETIME,
            @EndDate        DATETIME,
            @MinQty         INT,
            @MaxQty         INT;
        DECLARE Inserted_Cursor CURSOR FOR
        SELECT
            SpecialOfferID,
            ProductName,
            Description,
            DiscountPct,
            Type,
            Category,
            StartDate,
            EndDate,
            MinQty,
            MaxQty
        FROM inserted;

        OPEN Inserted_Cursor;

        FETCH NEXT FROM Inserted_Cursor INTO
            @SpecialOfferID,
            @ProductName,
            @Description,
            @DiscountPct,
            @Type,
            @Category,
            @StartDate,
            @EndDate,
            @MinQty,
            @MaxQty;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@ProductName IS NULL) OR NOT EXISTS(
                SELECT
                    SpecialOfferID
                FROM Sales.SpecialOffer
                WHERE SpecialOfferID = @SpecialOfferID)
            BEGIN
                INSERT INTO Sales.SpecialOffer (
                    Description,
                    DiscountPct,
                    Type,
                    Category,
                    StartDate,
                    EndDate,
                    MinQty,
                    MaxQty)
                VALUES (
                    @Description,
                    @DiscountPct,
                    @Type,
                    @Category,
                    @StartDate,
                    @EndDate,
                    @MinQty,
                    @MaxQty);

                SET @SpecialOfferID = SCOPE_IDENTITY();
            END;

            INSERT INTO Sales.SpecialOfferProduct (SpecialOfferID, ProductID)
            VALUES (
                @SpecialOfferID,
                (SELECT ProductID FROM Production.Product WHERE Name = @ProductName)
            )

            FETCH NEXT FROM Inserted_Cursor INTO
                @SpecialOfferID,
                @ProductName,
                @Description,
                @DiscountPct,
                @Type,
                @Category,
                @StartDate,
                @EndDate,
                @MinQty,
                @MaxQty;
        END;

        CLOSE Inserted_Cursor;
        DEALLOCATE Inserted_Cursor;
    END;

    IF @Action = 'U'
    BEGIN
        IF EXISTS (
            SELECT SpecialOfferID FROM inserted
            EXCEPT
            SELECT SpecialOfferID FROM deleted)
        BEGIN
            RAISERROR(N'Cannot update product offers references', 10, -1);
        END;

        UPDATE dest
        SET
            dest.Description = src.Description,
            dest.DiscountPct = src.DiscountPct,
            dest.Type = src.Type,
            dest.Category = src.Category,
            dest.StartDate = src.StartDate,
            dest.EndDate = src.EndDate,
            dest.MinQty = src.MinQty,
            dest.MaxQty = src.MaxQty
        FROM Sales.SpecialOffer dest
        INNER JOIN inserted src ON src.SpecialOfferID = dest.SpecialOfferID;  
    END;
END;

DECLARE @ProductID INT;

INSERT INTO dbo.ProductsSpecialOffers (
    ProductName, Description, Category, StartDate, EndDate, DiscountPct, MinQty, Type)
VALUES (
    'Adjustable Race', 'Test', 'Test', GETDATE(), GETDATE(), 14.2, 0, 'Test');

SET @ProductID = (SELECT ProductID FROM dbo.ProductsSpecialOffers WHERE ProductName = 'Adjustable Race');

UPDATE dbo.ProductsSpecialOffers
    SET Description = 'New Test'
WHERE ProductID = @ProductID;

DELETE FROM dbo.ProductsSpecialOffers
WHERE ProductID = @ProductID;
