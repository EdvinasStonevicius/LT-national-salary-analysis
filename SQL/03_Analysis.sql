USE salary_lt;


-- Number of employees in groups (size of selected samples, insight on confidence)
-- Number of employees of each profession (total for both years)
SELECT 
    lpk,
    profession,
    COUNT(lpk) AS lpk_count
FROM
    employees
        JOIN
    lpk_profession USING (lpk)
GROUP BY lpk
ORDER BY lpk_count;

-- Number of employees in each sector (total for both years)
SELECT 
    nace,
    sector,
    COUNT(nace) AS nace_count
FROM
    employees
        JOIN
    economic_sector USING (nace)
GROUP BY nace
ORDER BY nace_count;

-- Number of employees with particular education degrees (total for both years)
SELECT 
    education,
    degree,
    COUNT(education) AS education_count
FROM
    employees
        JOIN
    education_degree USING (education)
GROUP BY education
ORDER BY education_count;



-- View of mean, standard deviation and coefficient of variation in different groups 
DROP VIEW IF EXISTS hourly_rate_mean_variation;
CREATE VIEW hourly_rate_mean_variation AS
    SELECT 
        'year' AS dimension,
        year,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY year 
    UNION SELECT 
        'gender' AS dimension,
        gender,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY gender 
    UNION SELECT 
        'nace' AS dimension,
        nace,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY nace 
    UNION SELECT 
        'collective' AS dimension,
        collective,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY collective 
    UNION SELECT 
        'contract' AS dimension,
        contract,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY contract 
    UNION SELECT 
        'education' AS dimension,
        education,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY education 
    UNION SELECT 
        'lpk' AS dimension,
        lpk,
        COUNT(*) AS count,
        ROUND(AVG(hourly_rate), 2) AS mean,
        ROUND(STD(hourly_rate), 2) AS sd,
        ROUND(STD(hourly_rate) / AVG(hourly_rate), 2) AS cv
    FROM
        employees
    GROUP BY lpk;

  
-- Stored procedure for queries on hourly rate statistics  
DROP PROCEDURE IF EXISTS hr_statistics;

DELIMITER //
CREATE PROCEDURE hr_statistics(
                    IN select_dimension varchar(30))
BEGIN
SELECT 
    *
FROM
    hourly_rate_mean_variation
WHERE find_in_set(dimension, select_dimension) 
    ORDER BY dimension, mean;
END //
DELIMITER ;

CALL hr_statistics( 'year,gender');


-- Average hourly rate of profession with large (eg. 100) sample in both 2014 and 2018 (using CTE) 
SET @size_gt = 100;
WITH 
hr14 AS (  -- Average for 2014
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014,
            count(lpk) AS n_2014
	FROM employees
	WHERE year = 2014
	GROUP BY lpk
    HAVING n_2014 > @size_gt),
 hr18 AS ( -- Average for 2018
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018,
            count(lpk) AS n_2018
	FROM employees
	WHERE year = 2018
	GROUP BY lpk
     HAVING n_2018 > @size_gt)
SELECT lpk,
	profession,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) AS difference,
    round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) AS percent_change
FROM lpk_profession -- INNER JOIN to keep only professions with more than selected number of employees and
JOIN hr14 USING (lpk) --  only professions with data for both years, combine with LEFT/RIGHT JOINS
JOIN hr18 USING (lpk) --  to get all professions including with no data or data for just one year
ORDER BY percent_change DESC;

-- Average hourly rate in economic sectors for 2014, 2018 and relative change
-- (using CTE and OVER) 
SET @size_gt = 100;
WITH 
hr14 AS (  -- Average for 2014
	SELECT nace,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014,
            count(nace) AS n_2014
	FROM employees
	WHERE year = 2014
	GROUP BY nace
    HAVING n_2014 > @size_gt),
 hr18 AS ( -- Average for 2018
	SELECT nace,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018,
            count(nace) AS n_2018
	FROM employees
	WHERE year = 2018
	GROUP BY nace
     HAVING n_2018 > @size_gt)
SELECT nace,
	sector,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) AS difference,
	round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) AS percent_change,
	round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100 -
		AVG((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100) 
		OVER (), 2 ) AS perc_dev_from_average -- Shows relative gains and losses
    
FROM  economic_sector -- INNER JOIN to keep only sectors with more than selected number of employees and
JOIN hr14 USING (nace) --  only sectors with data for both years, combine with LEFT/RIGHT JOINS
JOIN hr18 USING (nace) --  to get all sectors including with no data or data for just one year
ORDER BY percent_change DESC;

-- Create view with average hourly rate of female and male employees in combination of sectors and education degrees  
DROP VIEW IF EXISTS gender_hr;
CREATE VIEW gender_hr AS
WITH 
hr_f AS (  -- Average for females with different education in different sectors
	SELECT nace,
			education,
            year,
			round(AVG(hourly_rate), 2) AS hourly_rate_f,
            count(nace) AS n_female
	FROM employees
	WHERE gender = 'F' 
	GROUP BY nace, education, year),
 hr_m AS ( -- Average for males with different education in different sectors
	SELECT nace,
			education,
            year,
			round(AVG(hourly_rate), 2) AS hourly_rate_m,
            count(nace) AS n_male
	FROM employees
	WHERE gender = 'M' 
	GROUP BY nace, education, year)
SELECT nace,
	  education,
	  sector,
    degree,
    year,
    n_female,
    n_male,
    hourly_rate_f,
    hourly_rate_m,
    round(hourly_rate_m - hourly_rate_f, 2) AS difference,
	round((hourly_rate_m - hourly_rate_f) / hourly_rate_f *100, 2) AS percent_diff	
FROM hr_f							
FULL JOIN hr_m USING (nace, education, year)	-- FULL JOIN to keep all records
JOIN economic_sector USING (nace)				-- INNER JOIN to keep only sectors with emploees
JOIN education_degree USING (education)			-- INNER JOIN to keep only emploee degrees
-- WHERE n_female >= 10 AND n_male >= 10 		-- If needed, remove combinations with small sample
WITH CHECK OPTION;


-- Sectors where female hourly rate higher than male  
SELECT  DISTINCT nace,
		sector
FROM
    gender_hr
WHERE percent_diff < 0  					-- Negative difference - female hr is higher
	AND n_female >= 50 AND n_male >= 50 	-- If needed, remove combinations with small sample
ORDER BY percent_diff;


-- Stored procedure for queries on gender hourly rate diferences  
DROP PROCEDURE IF EXISTS gender_hr_difference;

DELIMITER //
CREATE PROCEDURE gender_hr_difference(
                    IN education_code varchar(50),
                    IN nace_code varchar(50),
                    IN survey_year varchar(50))
BEGIN
SELECT 
    *
FROM
    gender_hr
WHERE find_in_set(education, education_code)  
	AND find_in_set(nace, nace_code)
    AND find_in_set(year, survey_year)
    ORDER BY nace;
END //
DELIMITER ;

CALL gender_hr_difference( 'G1,G2,G3,G4', 'Q,P,I', '2014,2018');


-- Distribution of education degrees in sectors (total for both years) , %
SELECT 
    nace,
    sector,
    ROUND(COUNT(CASE
                WHEN education = 'G1' THEN nace
                ELSE NULL
            END) / COUNT(nace) * 100,
            2) AS perc_G1,
    ROUND(COUNT(CASE
                WHEN education = 'G2' THEN nace
                ELSE NULL
            END) / COUNT(nace) * 100,
            2) AS perc_G2,
    ROUND(COUNT(CASE
                WHEN education = 'G3' THEN nace
                ELSE NULL
            END) / COUNT(nace) * 100,
            2) AS perc_G3,
    ROUND(COUNT(CASE
                WHEN education = 'G4' THEN nace
                ELSE NULL
            END) / COUNT(nace) * 100,
            2) AS perc_G4
FROM
    employees
        JOIN
    economic_sector USING (nace)
GROUP BY nace
ORDER BY perc_G1;

-- Number of hours per year and month (October) on average employees work in sectors 
-- (based on salary and hourly rate and hours field)
WITH averages AS
(SELECT 
    nace,
    AVG(gross_salary) AS annual,
    AVG(gross_salary_oct) AS monthly,
    AVG(hourly_rate) AS hourly,
    ROUND(AVG(hours), 0) AS hours_field
FROM
    employees
GROUP BY nace)
   SELECT 
    nace,
    sector,
    ROUND(annual / hourly, 0) AS hours_year,
    ROUND(monthly / hourly, 0) AS hours_month,
    hours_field
FROM
    averages
        JOIN
    economic_sector USING (nace)
ORDER BY hours_year; 


-- Sectors and professions with largest reported bonuses
SELECT 
    nace,
    sector,
    COUNT(nace) AS count,
    ROUND(bonuses / total * 100, 2) AS perc_annual_bonus,
    ROUND((bonuses_oct + bonuses_add_oct) / total_oct * 100,
            2) AS perc_monthly_bonus
FROM
    employees
        JOIN
    economic_sector USING (nace)
GROUP BY nace
HAVING perc_annual_bonus > 0 OR perc_monthly_bonus > 0 -- Very likely not all bonuses are included
ORDER BY perc_annual_bonus DESC; 

SELECT 
    lpk,
    profession,
    COUNT(lpk) AS count,
    ROUND(bonuses / total * 100, 2) AS perc_annual_bonus,
    ROUND((bonuses_oct + bonuses_add_oct) / total_oct * 100,
            2) AS perc_monthly_bonus
FROM
    employees
        JOIN
    lpk_profession USING (lpk)
GROUP BY lpk
HAVING perc_annual_bonus > 0 OR perc_monthly_bonus > 0 -- Very likely not all bonuses are included
ORDER BY perc_annual_bonus DESC; 