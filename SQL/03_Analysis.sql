USE salary_lt;

-- Number of employees of each profession
SELECT e.lpk, p.profession, count(lpk) as lpk_count
FROM employees e
INNER JOIN lpk_profession p USING(lpk) 
GROUP BY lpk
ORDER BY lpk_count DESC;

