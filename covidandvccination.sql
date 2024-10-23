 USE protfolioproject;
 SELECT * FROM covid19 ;
 SELECT * FROM vaccination ;
 
-- data that we use
SELECT Country, Date_reported, cumulative_cases, New_cases , cumulative_deaths
FROM covid19 ORDER BY 1, 2;

-- LOKING AT TOTAL CASES VS TOTAL DEATHS 
-- shows the likelihood of dying if you contract  in your country
SELECT Country, Date_reported, cumulative_cases , cumulative_deaths, (cumulative_deaths/cumulative_cases)*100 as deathpersentage
FROM covid19
WHERE country LIKE '%ndia%'
ORDER BY Cumulative_cases;

-- looking at countries highest infection rates(which country got highest infection )
SELECT Country, Cumulative_cases
FROM covid19
ORDER BY Cumulative_cases DESC
LIMIT 1;

-- how many pepople got covid by country 
SELECT Country,Date_reported,SUM(cumulative_cases) total_population_got_covid
FROM covid19
GROUP BY 1,2;

-- total cases per countries
SELECT Country,sum(cumulative_cases) as total_case
FROM covid19
GROUP BY Country;

-- total deaths per countries
SELECT Country,sum(cumulative_deaths) as total_deaths,
COUNT(DISTINCT Date_reported) AS report_count
FROM covid19
GROUP BY Country;

-- countries with deathspersentage
SELECT  Country, cumulative_cases,cumulative_deaths, (cumulative_deaths/cumulative_cases)*100 as deathpersentage
FROM covid19
WHERE Country IS NOT NULL
ORDER BY 1, 2 ;

-- continents(who-region) with a highestdeath rate
SELECT WHO_region,max(cumulative_deaths) as totaldeathcount
FROM covid19
WHERE WHO_region IS NOT NULL
GROUP BY WHO_region
ORDER BY totaldeathcount DESC;

-- countries with maximumdeath rate peaksituation 
SELECT Country,max(cumulative_deaths) as totaldeathcount
FROM covid19
WHERE Country IS NOT NULL
GROUP BY Country
ORDER BY totaldeathcount DESC;

-- Globlenumber of people got affected, totaldeaths, death-persantage
SELECT SUM(New_cases) AS total_cases, SUM(New_deaths) AS total_deaths, (SUM(New_deaths) / SUM(New_cases))* 100 AS death_percentage
FROM covid19 ;

   --    --  --  --  -- 
alter table  vaccination  
rename column Entity to Country;
ALTER TABLE vaccination 
RENAME COLUMN `COVID-19 doses (daily, 7-day average, per million people)` TO vaccindose ;

SELECT * FROM vaccination ;

-- join tables
SELECT  * FROM  covid19 as cov19
join vaccination as vacc
ON cov19.Country = vacc.Country AND
cov19.Date_reported = vacc.Date_report;

-- looking at total people vs  avg_vaccinatons(7 days per million people) :(what presantage of people got vaccination per day)
SELECT cov19.WHO_region,cov19.Country,cov19.Date_reported,vacc.vaccindose,
sum(vaccindose) OVER (PARTITION BY cov19.Country ORDER BY cov19.Country, vacc.Date_report ) as rollingtotal7days
FROM  covid19 AS cov19
JOIN vaccination AS vacc 
ON cov19.Country = vacc.Country AND
cov19.Date_reported = vacc.Date_report
where WHO_region IS NOT NULL
ORDER BY 2, 3;


--  like hood country how many pepole got vaccination on days
 SELECT cov19.WHO_region,cov19.Country,cov19.Date_reported,vacc.vaccindose,
sum(vaccindose) OVER (PARTITION BY cov19.Country ORDER BY cov19.Country, vacc.Date_report ) as rollingtotal7days
FROM  covid19 AS cov19
JOIN vaccination AS vacc 
ON cov19.Country = vacc.Country AND
cov19.Date_reported = vacc.Date_report
where vacc.Country   like '%ndia%' 
ORDER BY 2, 3;

-- how many percentage people got vaccination per day as seven day average how many persentpeople got vaccination
 -- running total and persantage per 7day (352264.50402299996 /7)= then answer / 1000000 = ans that many people got vaccanation 

-- use ctes 

with  peoplepercent
as 
(
SELECT cov19.WHO_region,cov19.Country,cov19.Date_reported,vacc.vaccindose,
sum(vaccindose) OVER (PARTITION BY cov19.Country ORDER BY cov19.Country, vacc.Date_report ) as rollingtotal7days
FROM  covid19 AS cov19
JOIN vaccination AS vacc 
ON cov19.Country = vacc.Country AND
cov19.Date_reported = vacc.Date_report
WHERE vacc.Country  LIKE '%ndia%' OR vacc.Country LIKE '%hina%'
)
SELECT * ,(rollingtotal7days/ 1400000000.0) * 100
FROM peoplepercent
ORDER BY Country, rollingtotal7days;

--  for creating view to data visulization

CREATE VIEW percentpopulationvaccination as 
SELECT cov19.WHO_region,cov19.Country,cov19.Date_reported,vacc.vaccindose,
sum(vaccindose) OVER (PARTITION BY cov19.Country ORDER BY cov19.Country, vacc.Date_report ) as rollingtotal7days
FROM  covid19 AS cov19
JOIN vaccination AS vacc 
ON cov19.Country = vacc.Country AND
cov19.Date_reported = vacc.Date_report
where WHO_region IS NOT NULL
ORDER BY 2, 3;

 SELECT * FROM percentpopulationvaccination;





