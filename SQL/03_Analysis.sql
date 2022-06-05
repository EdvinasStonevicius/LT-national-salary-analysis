USE salary_lt;

/*Number of employees in groups (size of selected samples, insight on confidence)
-- Number of employees of each profession (total for both years)
SELECT 	lpk,
		profession,
		count(lpk) AS lpk_count
FROM employees
JOIN lpk_profession USING(lpk) 
GROUP BY lpk
ORDER BY lpk_count;

-- Number of employees in each sector (total for both years)
SELECT 	nace,
		sector,
		count(nace) AS nace_count
FROM employees
JOIN economic_sector USING(nace) 
GROUP BY nace
ORDER BY nace_count;

-- Number of employees with particular education degrees (total for both years)
SELECT 	education,
		degree,
		count(education) AS education_count
FROM employees
JOIN education_degree USING(education) 
GROUP BY education
ORDER BY education_count;
*/
/*-- Average hourly rate of profession in 2014 and 2018 including proffesions with small sample and data for one year 
WITH 
hr14 AS (  -- Average for 2014
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014,
            count(lpk) AS n_2014
	FROM employees
	WHERE year = 2014
	GROUP BY lpk),
 hr18 AS ( -- Average for 2018
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018,
            count(lpk) AS n_2018
	FROM employees
	WHERE year = 2018
	GROUP BY lpk)
SELECT lpk,
	profession,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) AS difference,
    round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) AS percent_change
FROM lpk_profession -- INNER JOIN to keep only professions with more than selected number of employees and
LEFT JOIN hr14 USING (lpk) --  only professions with data for both years, combine with LEFT/RIGHT JOINS
LEFT JOIN hr18 USING (lpk) --  to get all professions including with no data or data for just one year
ORDER BY percent_change DESC;
*/
/*-- Average hourly rate of profession with large (eg. 100) sample in both 2014 and 2018 (using CTE) 
WITH 
hr14 AS (  -- Average for 2014
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014,
            count(lpk) AS n_2014
	FROM employees
	WHERE year = 2014
	GROUP BY lpk
    HAVING n_2014 > 100),
 hr18 AS ( -- Average for 2018
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018,
            count(lpk) AS n_2018
	FROM employees
	WHERE year = 2018
	GROUP BY lpk
     HAVING n_2018 > 100)
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
*/
/*-- Average hourly rate in economic sectors for 2014 and 2018 and relative change
-- (using CTE and OVER) 
WITH 
hr14 AS (  -- Average for 2014
	SELECT nace,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014,
            count(nace) AS n_2014
	FROM employees
	WHERE year = 2014
	GROUP BY nace
    HAVING n_2014 > 100),
 hr18 AS ( -- Average for 2018
	SELECT nace,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018,
            count(nace) AS n_2018
	FROM employees
	WHERE year = 2018
	GROUP BY nace
     HAVING n_2018 > 100)
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
*/
/*-- Average hourly rate of female and male employees in combination of sectors and education degrees  
WITH 
hr_f AS (  -- Average for females with different education in different sectors
	SELECT nace,
			education,
            year,
			round(AVG(hourly_rate), 2) AS hourly_rate_f,
            count(nace) AS n_female
	FROM employees
	WHERE sex = 'F' 
	GROUP BY nace, education, year),
 hr_m AS ( -- Average for males with different education in different sectors
	SELECT nace,
			education,
            year,
			round(AVG(hourly_rate), 2) AS hourly_rate_m,
            count(nace) AS n_male
	FROM employees
	WHERE sex = 'M' 
	GROUP BY nace, education, year)
SELECT nace,
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
WHERE n_female >= 10 AND n_male >= 10 			-- Remove combinations with small sample;
*/
/*-- Ratio of emploees with lowest and highest education in sectors (total for both years)
WITH n_employees_sector AS (  -- Number of emmployees in sector
	SELECT 	nace,
			sector,
			count(nace) AS nace_count
	FROM employees
	JOIN economic_sector USING(nace) 
	GROUP BY nace
	ORDER BY nace_count)
SELECT education,
		degree,
		sector,
        count(sector) AS with_selected_degree,
        nace_count AS total_emploee_number,
		round(count(sector)/ nace_count *100, 2) AS percent_of_total    
FROM employees
JOIN education_degree USING(education) 
JOIN n_employees_sector USING(nace)  
WHERE education IN ('G1', 'G4' )
GROUP BY sector, education
ORDER BY education, percent_of_total  DESC;
*/
/*-- Distribution of education degrees in sectors (total for both years) 
WITH 
n_employees_sector AS (  -- Number of emmployees in sector
	SELECT 	nace,
			sector,
			count(nace) AS nace_count
	FROM employees
	JOIN economic_sector USING(nace) 
	GROUP BY nace
	ORDER BY nace_count),
g1 AS (SELECT 	nace,
				count(nace) AS with_G1
		FROM employees
		WHERE education = 'G1'
		GROUP BY nace),
g2 AS (SELECT 	nace,
				count(nace) AS with_G2
		FROM employees
		WHERE education = 'G2'
		GROUP BY nace),
g3 AS (SELECT 	nace,
				count(nace) AS with_G3
		FROM employees
		WHERE education = 'G3'
		GROUP BY nace),
g4 AS (SELECT 	nace,
				count(nace) AS with_G4
		FROM employees
		WHERE education = 'G4'
		GROUP BY nace)
SELECT 	nace,
		sector,
        ROUND(with_G1 / nace_count *100, 2) AS perc_G1,
		ROUND(with_G2 / nace_count *100, 2) AS perc_G2,
		ROUND(with_G3 / nace_count *100, 2) AS perc_G3,
		ROUND(with_G4 / nace_count *100, 2) AS perc_G4
FROM n_employees_sector
JOIN g1 USING(nace)
JOIN g2 USING(nace)
JOIN g3 USING(nace)
JOIN g4 USING(nace)
ORDER BY perc_G1;
*/

-- !!!!!!!! surasti alternatyvas su  sukurtom funkcijom ir parametrais???