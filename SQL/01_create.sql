/* */ 
CREATE SCHEMA `salary_lt`;
USE salary_lt;
 
 -- Data on emplyees (main dataset)
CREATE TABLE IF NOT EXISTS salary_lt.employees
(`_type` varchar(255),
 `_id` varchar(255),
 `_revision` varchar(255),
 `year` int,
 `nace` varchar(2),
 `key_l` int,
 `key_e` int PRIMARY KEY,
 `location` varchar(2),
 `esize_cd` int,
 `esize_class` varchar(6),
 `collective` varchar(1),
 `sex` varchar(1),
 `age_class` varchar(5),
 `lpk` varchar(3),
 `education` varchar(2),
 `experience` int,
 `arrangement` varchar(2),
 `work_part` double,
 `contract` varchar(1),
 `weeks` double,
 `hours` int,
 `overtime` int,
 `vacation` double,
 `gross_salarie` double,
 `bonuses` double,
 `gross_salarie_oct` double,
 `bonuses_oct` double,
 `bonuses_add_oct` double,
 `hourly_rate` double,
 `weight` double);
 
TRUNCATE salary_lt.employees;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DarboUzmokestis2014.csv' INTO TABLE salary_lt.employees
	character set utf8mb4
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DarboUzmokestis2018.csv' INTO TABLE salary_lt.employees
	character set utf8mb4
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;

CREATE TABLE IF NOT EXISTS salary_lt.collective_type
(`collective` varchar(1) PRIMARY KEY,
 `collective_type` varchar(50));

 TRUNCATE salary_lt.collective_type; 
INSERT INTO 
	salary_lt.collective_type()
VALUES
	('A', 	'Nacionalinė'),
	('B',	'Šakos (gamybos, paslaugų, profesinė)'),
	('C',	'Teritorinė (savivaldybės, apskrities)'),
	('D',	'Įmonės'),
	('E',	'Vietos vieneto'),
	('F', 	'Kita'),
	('N',	'Nesudaryta');	
   
CREATE TABLE IF NOT EXISTS salary_lt.education_degree
(`education` varchar(2) PRIMARY KEY,
 `degree` varchar(100));

TRUNCATE salary_lt.education_degree; 
INSERT INTO 
	salary_lt.education_degree()
VALUES
	('G1', 	'Pradinis arba pagrindinis'),
	('G2',	'Vidurinis (Povidurinis profesinis, Specialusis vidurinis, Aukštesnysis)'),
	('G3',	'Aukštasis (bakalauro studijos)'),
	('G4',	'Aukštasis (magistro studijos ir doktorantūra)');	
   

CREATE TABLE IF NOT EXISTS salary_lt.contract_time_limit
(`contract` varchar(1) PRIMARY KEY,
 `time_limit` varchar(50));
 
TRUNCATE salary_lt.contract_time_limit;
INSERT INTO 
	salary_lt.contract_time_limit
VALUES
	('A', 	'Neterminuota'),
	('B',	'Terminuota'),
	('C',	'Mokinys');	
 

CREATE TABLE IF NOT EXISTS salary_lt.LPK_profession
(`lpk` varchar(3) PRIMARY KEY,
 `profession` varchar(255));
 
TRUNCATE salary_lt.LPK_profession;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LPK2012.txt' INTO TABLE salary_lt.LPK_profession
	character set utf8mb4
	FIELDS TERMINATED BY '\t'
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;



CREATE TABLE IF NOT EXISTS salary_lt.economic_sector
(`nace` varchar(1) PRIMARY KEY,
 `sector` varchar(255));
 
TRUNCATE salary_lt.economic_sector;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/EVRK2_section.txt' INTO TABLE salary_lt.economic_sector
	character set utf8mb4
	FIELDS TERMINATED BY '\t'
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;
/*       */