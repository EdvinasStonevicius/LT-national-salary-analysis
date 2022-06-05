USE salary_lt;

/*-- Number of employees of each profession
SELECT 	e.lpk,
		p.profession,
		count(lpk) AS lpk_count
FROM employees e
JOIN lpk_profession p USING(lpk) 
GROUP BY lpk
ORDER BY lpk_count DESC;
*/
/*-- Average hourly rate of profession in 2014 and 2018 including proffesions with small pool and data for one year 
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
/*-- Average hourly rate of profession with large (eg. 100) pool in both 2014 and 2018 (using CTE) 
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
/*-- Average hourly rate in 2018 of female and male employees in combination of sectors and education degrees  
WITH 
hr_f AS (  -- Average for females with different education
	SELECT nace,
			education,
			round(AVG(hourly_rate), 2) AS hourly_rate_f,
            count(nace) AS n_female
	FROM employees
	WHERE sex = 'F' AND year = 2018
	GROUP BY nace, education),
 hr_m AS ( -- Average for males with different education
	SELECT nace,
			education,
			round(AVG(hourly_rate), 2) AS hourly_rate_m,
            count(nace) AS n_male
	FROM employees
	WHERE sex = 'M' AND year = 2018
	GROUP BY nace, education)
SELECT nace,
	sector,
    degree, 
    n_female,
    n_male,
    hourly_rate_f,
    hourly_rate_m,
    round(hourly_rate_m - hourly_rate_f, 2) AS difference,
	round((hourly_rate_m - hourly_rate_f) / hourly_rate_f *100, 2) AS percent_diff	
FROM hr_f							
FULL JOIN hr_m USING (nace, education)	-- FULL JOIN to keep all records
JOIN economic_sector USING (nace)		-- INNER JOIN to keep only sectors with emploees
JOIN education_degree USING (education)	-- INNER JOIN to keep only emploees degree
WHERE n_female >= 10 AND n_male >= 10 	-- Remove combinations with small sample
ORDER BY  nace, hourly_rate_f;
*/

-- !!!!!!!! surasti alternatyvas su  sukurtom funkcijom ir parametrais???