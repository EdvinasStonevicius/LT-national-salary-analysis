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
/*-- Average salary of each profession in 2018
SELECT 	e.lpk,
		p.profession,
        round(AVG(total), 0) AS avg_total,
        round(AVG(total_oct), 0) AS avg_total_oct,
        round(AVG(hourly_rate), 2) AS avg_hourly_rate
FROM employees e
JOIN lpk_profession p USING(lpk) 
WHERE year = 2018
GROUP BY lpk
ORDER BY avg_hourly_rate DESC;
*/
/*-- Average hourly rate of profession in 2014 and 2018 
SELECT 
	lpk,
	hr14.profession,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) AS difference,
    round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) AS percent_change
FROM 
	(SELECT p.lpk,
			p.profession,
			round(AVG(e14.hourly_rate), 2) AS hourly_rate_2014
	FROM employees e14
	JOIN lpk_profession p USING(lpk) 
	WHERE year = 2014
	GROUP BY lpk) AS hr14
JOIN 
	(SELECT p.lpk,
			p.profession,
			round(AVG(e18.hourly_rate), 2) AS hourly_rate_2018
	FROM employees e18
	JOIN lpk_profession p USING(lpk) 
	WHERE year = 2018
	GROUP BY lpk) AS hr18 
USING (lpk)
ORDER BY percent_change DESC; 
*/
/*-- Average hourly rate of profession with large pool in 2014 and 2018 (using CTE) 
WITH 
count_gt AS ( -- Professions with Number of employees greater than selected number (eg. 200)
SELECT 	lpk,
		count(lpk) AS lpk_count
FROM employees 
GROUP BY lpk
HAVING lpk_count > 200),
 hr14 AS (  -- Average for 2014
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2014
	FROM employees
	WHERE year = 2014
	GROUP BY lpk),
 hr18 AS ( -- Average for 2018
	SELECT lpk,
			round(AVG(hourly_rate), 2) AS hourly_rate_2018
	FROM employees
	WHERE year = 2018
	GROUP BY lpk)
SELECT lpk,
	profession,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) AS difference,
    round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) AS percent_change
FROM lpk_profession
JOIN count_gt USING (lpk) -- INNER JOIN to keep only professions with more than 200 employees and
JOIN hr14 USING (lpk) --  only professions with data for both years, combine with LEFT JOINS
JOIN hr18 USING (lpk) --  to get all professions including with no data or data for just one year
ORDER BY percent_change DESC;
*/
-- !!!!!!!! surasti alternatyvas su  sukurtom funkcijom ir parametrais???