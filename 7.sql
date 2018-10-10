USE AdventureWorks2012;
GO

DECLARE @xml XML = (
    SELECT
        dephist.StartDate AS 'Start',
        dephist.EndDate   AS 'End',
        dep.GroupName     AS 'Department/Group',
        dep.Name          AS 'Department/Name'
    FROM HumanResources.EmployeeDepartmentHistory dephist
    INNER JOIN HumanResources.Department dep ON dep.DepartmentID = dephist.DepartmentID
    FOR XML PATH ('Transaction'), ROOT ('History')
);

CREATE TABLE #TempXML (
    DepartmentXML XML
);

INSERT INTO #TempXML (DepartmentXML)
SELECT
    DepartmentXML.query('.')
FROM @xml.nodes('//Department') AS ResultXML(DepartmentXML);

SELECT
    *
FROM #TempXML;