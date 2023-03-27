-- Group By and Order By

SELECT *
FROM EmployeeDemographics

-- You can put multiple columns as long as they are included in the group by statement

SELECT Gender, count(Gender) AS CountGender
FROM EmployeeDemographics
Where Age > 31
GROUP BY Gender

SELECT Gender, count(Gender) AS CountGender
FROM EmployeeDemographics
Where Age > 31
GROUP BY Gender
Order BY CountGender

SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC, Gender

-- We can also use numbers in the order by
SELECT *
FROM EmployeeDemographics
ORDER BY 1 DESC

-- Joins

SELECT *
FROM EmployeeDemographics

SELECT *
FROM EmployeeSalary

-- When doing joins you need to have a similar column in both tables (primary/foriegn key)

SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM EmployeeDemographics
Left Outer Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

-- Who has the highest salary besides michael? 
SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, Salary
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
Where FirstName <> 'Michael'
Order By Salary DESC

-- What is the average salary of our salesman? 
SELECT JobTitle, avg(Salary)
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
where JobTitle = 'Salesman'
Group By JobTitle

-- Unions: Allow you to select all data from both tables and put it into 1 output
-- Should use the same number of columns 
-- Union All will group all info even if there are duplicates 

SELECT EmployeeId, FirstName, Age
FROM EmployeeDemographics
UNION 
SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
Order By EmployeeID

--Case Statements

SELECT FirstName, LastName, Age,
CASE 
	When Age > 30 Then 'Old'
	When Age Between 27 and 30 THEN 'Young'
	Else 'Baby'
	END 
FROM EmployeeDemographics
Where Age is NOT NULL
Order By Age


SELECT FirstName, LastName, Age,
CASE 
	When Age > 30 Then 'Old'
	When Age = 38 THEN 'Stanley'
	Else 'Baby'
	END 
FROM EmployeeDemographics
Where Age is NOT NULL
Order By Age

-- Calculate what employee salaries will be after raises
SELECT FirstName, LastName, JobTitle, Salary,
CASE 
	WHEN JobTitle = 'Salesman' THEN Salary * (1.1)
	WHEN JobTitle = 'HR' THEN Salary * (1.01)
	WHEN Jobtitle = 'Accountant' THEN Salary * (1.05)
	ELSE Salary * (1.03)
END AS SalaryAfterRaise
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

-- Having Clause 

SELECT JobTitle, COUNT(JobTitle)
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
Group BY JobTitle
Having Count(JobTitle) > 1

SELECT JobTitle, avg(Salary)
FROM EmployeeDemographics
Join EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
Group BY JobTitle
Having avg(Salary) > 45000
Order By avg(Salary)

-- Updating/Deleting 
-- Update will alter a pre-existing row
-- Deleting will specify what rows you want to remove

SELECT *
FROM EmployeeDemographics

Update EmployeeDemographics
SET Age = 37
Where EmployeeID = 1013 AND FirstName = 'Darryl' AND LastName = 'Philbin' 

-- There is no way to get data back after the delete statement is run 
DELETE FROM EmployeeDemographics
WHERE EmployeeID = 1014

-- Aliasing 
-- Don't have to use as for naming 
SELECT FirstName + ' ' + LastName as FullName
FROM EmployeeDemographics

-- When aliasing a table name, make sure to include the alias before your selection 
SELECT Demo.EmployeeID, Sal.Salary
FROM EmployeeDemographics AS Demo
Join EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID

	-- Try not to use just an 'a' or 'b' to alias

-- Partition By 

SELECT FirstName, LastName, Gender, Salary
, Count(gender) OVER (Partition By Gender) As TotalGender
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Sal.EmployeeID = Dem.EmployeeID

SELECT FirstName, LastName, Gender, Salary, Count(gender) 
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Sal.EmployeeID = Dem.EmployeeID
Group By FirstName, LastName, Gender, Salary


SELECT Gender, Count(gender) 
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Sal.EmployeeID = Dem.EmployeeID
Group By Gender

-- CTEs
-- Only created in memory as opposed to temp tables

With CTE_Employee as 
(SELECT FirstName, LastName, Gender, Salary
, Count(gender) OVER (Partition By Gender) As TotalGender
, avg(Salary) OVER (Partition By Gender) as AvgSalary
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Sal.EmployeeID = Dem.EmployeeID 
WHERE Salary > '45000'
)
Select *
FROM CTE_Employee
  -- Each time you run it, make sure to include the whole CTE in the query
  -- Select statement must be right after the aggregate function 

-- Temp Tables 
-- You can hit off the table mulitple times unlike CTE

CREATE TABLE #Temp_Employee (
EmployeeID int,
JobTitle Varchar(255),
Salary int
)

Select *
FROM #Temp_Employee

INSERT INTO #Temp_Employee VALUES (
'1001', 'HR', '45000'
)

-- Taking employee salary table data and inserting it into the temp table
INSERT INTO #Temp_Employee
SELECT *
FROM EmployeeSalary

DROP TABLE IF Exists #Temp_Employee2 -- Helps with deleting tables to create again 
CREATE TABLE #Temp_Employee2 (
JobTitle varchar(50),
EmployeesPerJob int,
AvgAge int,
AvgSalary int)

INSERT INTO #Temp_Employee2
SELECT JobTitle, Count(JobTitle), AVG(Age), AVG(Salary)
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID
Group By JobTitle

SELECT * 
FROM #Temp_Employee2

-- String Functions
CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert')
,('  1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')

Select *
From EmployeeErrors

-- Using Trim, LTRIM, RTRIM
SELECT EmployeeID, TRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, LTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, RTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

-- Using Replace

Select LastName, REPLACE(LastName, '- Fired', '') As LastNameFixed
From EmployeeErrors

-- Using Substring

Select Substring(FirstName,1,3) -- 1 means start from 1st character/int. 3 means go 3 characters/int away 
From EmployeeErrors

SELECT Err.FirstName, SUBSTRING(err.FirstName,1,3), Dem.FirstName, SUBSTRING(Dem.FirstName,1,3)
FROM EmployeeErrors AS Err
JOIN EmployeeDemographics AS Dem
	ON SUBSTRING(err.FirstName,1,3) = SUBSTRING(Dem.FirstName,1,3)

	-- Gender, LastName, Age, DOB are all good ways to fuzzy match

-- Using Upper and Lower 

Select FirstName, LOWER(FirstName)
FROM EmployeeErrors

Select FirstName, Upper(FirstName)
FROM EmployeeErrors

-- Stored Procedures 
-- Procedures will be stored in the Programmability Folder on left hand side (Under Views and Synonyms) 
CREATE PROCEDURE Test
AS 
SELECT *
FROM EmployeeDemographics


EXEC Test -- Runs stroed procedure


CREATE PROCEDURE Temp_Employee
AS 
CREATE TABLE #Temp_Employee3 (
JobTitle varchar(255),
EmployeesPerJob int,
AvgAge int,
AvgSalary int
)

INSERT INTO #Temp_Employee
SELECT JobTitle, Count(JobTitle), AVG(Age), AVG(Salary)
FROM EmployeeDemographics AS Dem
JOIN EmployeeSalary AS Sal
	ON Dem.EmployeeID = Sal.EmployeeID
Group By JobTitle

SELECT * 
FROM #Temp_Employee3

-- You can also modify/alter stored procedures 

-- Subqueries

SELECT *
FROM EmployeeSalary

-- Subquery in SELECT

SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM EmployeeSalary) AS AllAvgSalary -- Will run inner query first, then outer
FROM EmployeeSalary

-- How to do it with partition by
SELECT EmployeeID, Salary, AVG(Salary) OVER () AS AllAvgSalary 
FROM EmployeeSalary

-- Doesn't work with Group By 
SELECT EmployeeID, Salary, AVG(Salary) AS AllAvgSalary 
FROM EmployeeSalary
GROUP BY EmployeeID, Salary
Order by 1,2

-- Subquery in the from statement 

SELECT a.EmployeeID, AllAvgSalary
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER () AS AllAvgSalary 
	  FROM EmployeeSalary) AS a

-- Subquery in the where statement 

SELECT EmployeeID, JobTitle, Salary
FROM EmployeeSalary
WHERE EmployeeID in (
		SELECT EmployeeID
		FROM EmployeeDemographics
		WHERE Age > 30)

-- Window Functions also known as analytical functions
SELECT * 
FROM EmployeeSalary

SELECT JobTitle, max(salary) AS maxsalary
FROM EmployeeSalary
GROUP BY JobTitle

SELECT e.*,
max(salary) over (partition by JobTitle) as maxsalary
FROM EmployeeSalary as e

-- row_number, rank, dense_rank, lead, lag
SELECT * from (
Select e.*,
ROW_NUMBER() Over(partition by JobTitle Order By EmployeeID) AS rn
from EmployeeSalary as e) AS X
where x.rn < 3


SELECT * FROM (
SELECT e.*,
rank() over (partition by JobTitle order by Salary desc) as rnk
FROM EmployeeSalary AS e) as x
Where x.rnk < 3

SELECT e.*,
rank() over (partition by JobTitle order by Salary desc) as rnk, -- rank will skip numbers in rank of the same value
dense_rank() over(partition by JobTitle order by Salary desc) as dense_rnk, -- Dense rank will not skip a value to rank
ROW_NUMBER() Over(partition by JobTitle Order By EmployeeID desc) AS rn
FROM EmployeeSalary as e

SELECT e.*, -- Lag will take the previous value and put it in the next 
lag(Salary) over(partition by JobTitle order by EmployeeID) as prevsalary, 
lag(Salary, 2, 0) over(partition by JobTitle order by EmployeeID) as prevsalary2
From EmployeeSalary as e

SELECT e.*,
lag(Salary) over(partition by JobTitle order by EmployeeID) as prevsalary,
case when e.Salary > lag(Salary) over(partition by JobTitle order by EmployeeID) then 'Higher than previous employee'
     when e.Salary < lag(Salary) over(partition by JobTitle order by EmployeeID) then 'lower than previous employee'
	 when e.Salary = lag(Salary) over(partition by JobTitle order by EmployeeID) then 'Same as previous employee'
	 END 
From EmployeeSalary as e

-- First value and last value
SELECT *,
first_value(JobTitle) over (partition by JobTitle order by Salary desc) as topsalary,
last_value(JobTitle) over (partition by JobTitle order by Salary desc) as bottomsalary
FROM EmployeeSalary

-- Frame clause: Frame is a subset of the partition
SELECT *,
first_value(JobTitle) 
	over (partition by JobTitle order by Salary desc) as topsalary,
last_value(JobTitle) 
	over (partition by JobTitle order by Salary desc range between unbounded preceding and unbounded following) as bottomsalary
FROM EmployeeSalary

--Nth value, not recognized as built-in function 
SELECT *,
first_value(JobTitle) 
	over (partition by JobTitle order by Salary desc) as topsalary,
last_value(JobTitle) 
	over (partition by JobTitle order by Salary desc range between unbounded preceding and unbounded following) as bottomsalary,
nth_value(JobTitle, 2)
	over (partition by JobTitle order by Salary desc) as nth_value
FROM EmployeeSalary

-- Ntile
-- write a query that can segregate all the high salaries, mid range salary, and cheaper salary
SELECT JobTitle,
case when x.buckets = 1 then 'High Salary'
	 when x.buckets = 2 then 'mid range salary'
	 when x.buckets = 3 then 'Cheaper salary'
	 END AS Salary_range
FROM (
SELECT *,
ntile(3) over (order by Salary desc) as buckets -- The (3) is to specify we want 3 buckets,EX:15 salesman would split into 3 buckets of 5
FROM EmployeeSalary
where JobTitle = 'Salesman'
) as x

-- cume_dist: cumulative distribution
-- Value --> 1 <= cume_dist > 0
-- formula = current row no (or row no with value same as current row) / total no of rows

-- Query to fetch all salaries which are constituting the first 30% 
SELECT *,
cume_dist() over (order by Salary desc) as cumulative_dist,
round(cume_dist() over (order by Salary desc)::numeric * 100, 2) as cumulative_dist_percent
FROM EmployeeSalary

-- Percent_rank (relative rank of the current row / Percentage ranking)
-- formula = current row no - 1 / total no of rows - 1

SELECT *,
percent_rank() over (order by Salary) as percentage_rank,
round(percent_rank() over (order by Salary)::numeric * 100, 2) as per_rank)
FROM EmployeeSalary