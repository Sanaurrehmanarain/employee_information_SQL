CREATE DATABASE employee_information;
USE employee_information;
SELECT
	COUNT(*)
FROM
	employee;
    
-- Question1:- How many employees are in each Payment Tier?

SELECT
	PaymentTier, COUNT(*) AS EmployeeCount
FROM
	employee
GROUP BY
	PaymentTier
ORDER BY
	PaymentTier;

-- Question2:- Calculate the average age of employees for each gender.

SELECT 
	Gender, AVG(age) AS AverageAge
FROM
	employee
GROUP BY
	Gender;
    
-- Question3:- Find the top 3 cities with the highest percentage of employees who have been benched at least once.

SELECT
    City,
    TotalEmployees,
    BenchedEmployees,
    BenchedEmployees / TotalEmployees AS BenchedPercentage
FROM (
    SELECT
        City,
        COUNT(*) AS TotalEmployees,
        SUM(CASE WHEN EverBenched = 'Yes' THEN 1 ELSE 0 END) AS BenchedEmployees
    FROM
        employee
    GROUP BY
        City
) AS Subquery
ORDER BY
    BenchedPercentage DESC
LIMIT 3;

-- Question4:- For each Education level, calculate the average experience in the current domain for employees who
-- joined before 2015 and those who joined in 2015 or later.

SELECT 
	Education,
    AVG(CASE WHEN JoiningYear < 2015 THEN ExperienceInCurrentDomain End) AS AvgExperienceBefore2015,
	AVG(CASE WHEN JoiningYear >= 2015 THEN ExperienceInCurrentDomain End) AS AvgExperience2015OrLater
FROM
	employee
GROUP BY
	Education;
    
-- Question5:- Calculate an Employee's likelihood to leave based on their Payment Tier, Experience in Current Domain,
-- and the average leave rate of their city.

WITH CityLeaveRates AS (
    SELECT City,
           AVG(CASE WHEN LeaveOrNot = 'Yes' THEN 1 ELSE 0 END) AS CityLeaveRate
    FROM employee
    GROUP BY City
)
SELECT 
    ei.PaymentTier,
    CASE 
        WHEN ei.ExperienceInCurrentDomain <= 3 THEN 'Low'
        WHEN ei.ExperienceInCurrentDomain <= 7 THEN 'Medium'
        ELSE 'High'
    END AS ExperienceLevel,
    ei.City,
    clr.CityLeaveRate,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN ei.LeaveOrNot = 'Yes' THEN 1 ELSE 0 END) AS LeavingEmployees,
    SUM(CASE WHEN ei.LeaveOrNot = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS GroupLeaveProbability
FROM employee ei
JOIN CityLeaveRates clr ON ei.City = clr.City
GROUP BY ei.PaymentTier, ExperienceLevel, ei.City, clr.CityLeaveRate
ORDER BY ei.PaymentTier, ExperienceLevel, ei.City;