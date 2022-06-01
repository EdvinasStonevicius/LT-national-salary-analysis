USE salary_lt;

-- Number of employees of each profession
SELECT 	e.lpk,
		p.profession,
		count(lpk) as lpk_count
FROM employees e
JOIN lpk_profession p USING(lpk) 
GROUP BY lpk
ORDER BY lpk_count DESC;

-- Average salary of each profession in 2018
SELECT 	e.lpk,
		p.profession,
        round(avg(total), 0) as avg_total,
        round(avg(total_oct), 0) as avg_total_oct,
        round(avg(hourly_rate), 2) as avg_hourly_rate
FROM employees e
JOIN lpk_profession p USING(lpk) 
WHERE year = 2018
GROUP BY lpk
ORDER BY avg_hourly_rate DESC;

-- !!!!!!!! surasti alternatyvas su temporar tables etc ir sukurti funkcijas???
-- Average hourly rate of profession in 2014 and 2018
SELECT 
	lpk,
	hr14.profession,
    hourly_rate_2014,
    hourly_rate_2018,
    round(hourly_rate_2018 - hourly_rate_2014, 2) as difference,
    round((hourly_rate_2018 - hourly_rate_2014) / hourly_rate_2014 *100, 2) as percent_change
FROM 
	(SELECT p.lpk,
			p.profession,
			round(avg(e14.hourly_rate), 2) as hourly_rate_2014
	FROM employees e14
	JOIN lpk_profession p USING(lpk) 
	WHERE year = 2014
	GROUP BY lpk) as hr14
JOIN 
	(SELECT p.lpk,
			p.profession,
			round(avg(e18.hourly_rate), 2) as hourly_rate_2018
	FROM employees e18
	JOIN lpk_profession p USING(lpk) 
	WHERE year = 2018
	GROUP BY lpk) as hr18 
USING (lpk)
ORDER BY percent_change DESC 
