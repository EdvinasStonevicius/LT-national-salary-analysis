USE salary_lt;

-- Remove leading X in nace field
UPDATE employees
SET nace = TRIM(LEADING 'X' FROM nace)
WHERE length(nace) > 1 AND key_e > 0 ; -- Table key used in statment to bypass safe mode

-- Change currency for salary in 2014 from LTL to EUR 
-- (Lithuania adopted the euro on 1 January 2015). 
UPDATE employees
SET gross_salary = round(gross_salary / 3.4528, 2),
	bonuses = round(bonuses / 3.4528, 2),
    gross_salary_oct = round(gross_salary_oct / 3.4528, 2),
    bonuses_oct = round(bonuses_oct / 3.4528, 2),
    bonuses_add_oct = round(bonuses_add_oct / 3.4528, 2),
    hourly_rate = round(hourly_rate / 3.4528, 2) 
WHERE year = 2014 AND key_e > 0 ; -- Table key used in statment to bypass safe mode

-- Add total salary and total october salary as a sum of gross and bounuses. 
-- Stored, because updates are unlikely.

ALTER TABLE employees
ADD COLUMN total DOUBLE 
GENERATED ALWAYS AS (gross_salary+bonuses) STORED AFTER bonuses, 
ADD COLUMN total_oct DOUBLE 
GENERATED ALWAYS AS (gross_salary_oct+bonuses_oct+bonuses_add_oct) STORED AFTER bonuses_add_oct;

-- Remove redundant fields
ALTER TABLE employees
DROP COLUMN _type, 
DROP COLUMN _id, 
DROP COLUMN _revision,
DROP COLUMN esize_cd;