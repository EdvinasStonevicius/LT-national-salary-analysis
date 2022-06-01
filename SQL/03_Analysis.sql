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

/* padaryti kad būtų skirtingi metai šalia
-- Average hourly rate of profession in 2014 and 2018
SELECT 	p.lpk,
		p.profession,
        round(avg(e14.hourly_rate), 2) as hourly_rate_2014,
        round(avg(e18.hourly_rate), 2) as hourly_rate_2018
FROM employees e14
JOIN employees e18 USING(lpk)
JOIN lpk_profession p USING(lpk) 
GROUP BY lpk
ORDER BY hourly_rate_2014 DESC;
*/