USE AdventureWorks2012;
GO

SELECT
    emp.BusinessEntityID,
    emp.JobTitle,
    AVG(payhist.Rate) AS AverageRate
FROM HumanResources.Employee emp
INNER JOIN HumanResources.EmployeePayHistory payhist ON payhist.BusinessEntityID = emp.BusinessEntityID
GROUP BY emp.BusinessEntityID, emp.JobTitle;

SELECT
    emp.BusinessEntityID,
    emp.JobTitle,
    payhist.Rate,
    CASE
        WHEN payhist.Rate <= 50 THEN 'Less or equal 50'
        WHEN payhist.Rate > 50 AND payhist.Rate <= 100 THEN 'More than 50 but less or equal 100'
        WHEN payhist.Rate > 100 THEN 'More than 100'
    END AS RateReport
FROM HumanResources.Employee emp
INNER JOIN HumanResources.EmployeePayHistory payhist ON payhist.BusinessEntityID = emp.BusinessEntityID;

SELECT
    dep.Name,
    MAX(payhist.Rate) AS MaxRate
FROM HumanResources.Employee emp
INNER JOIN HumanResources.EmployeeDepartmentHistory dephist ON dephist.BusinessEntityID = emp.BusinessEntityID
INNER JOIN HumanResources.Department dep                    ON dep.DepartmentID = dephist.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory payhist        ON payhist.BusinessEntityID = emp.BusinessEntityID
WHERE dephist.EndDate IS NULL
GROUP BY dep.Name
HAVING MAX(payhist.Rate) > 60
ORDER BY MaxRate;
