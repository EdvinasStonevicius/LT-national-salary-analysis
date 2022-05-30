USE salary_lt;

-- Remove leading X in nace field
UPDATE employees
SET nace = TRIM(LEADING 'X' FROM nace)
WHERE length(nace)>1 AND key_e> 0 ; -- Table key  used in statment to bypass safe mode


-- Remove redundant fields
ALTER TABLE employees
DROP COLUMN _type, 
DROP COLUMN _id, 
DROP COLUMN _revision;