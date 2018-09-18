USE AdventureWorks2012;
GO

SELECT
	BusinessEntityID,
	JobTitle,
	BirthDate,
	HireDate
FROM HumanResources.Employee
WHERE YEAR(BirthDate) > 1980
  AND HireDate > DATEFROMPARTS(2003, 4, 1);

SELECT
	SUM(VacationHours)  AS SumVacationHours,
	SUM(SickLeaveHours) AS SumSickLeaveHours
FROM HumanResources.Employee;

SELECT TOP 3
	BusinessEntityID,
	JobTitle,
	Gender,
	BirthDate,
	HireDate
FROM HumanResources.Employee
ORDER BY HireDate;