
-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
CREATE OR REPLACE VIEW v_trend_of_wages as
WITH total_wages AS (
    SELECT 
        branch.name AS branch_name,
        cp.payroll_year,
        SUM(cp.value) AS total_value
    FROM 
        (SELECT 
            industry_branch_code,
            payroll_year,
            value
         FROM czechia_payroll 
         WHERE value_type_code != 316) cp
    LEFT JOIN 
        (SELECT 
            name,
            code
         FROM czechia_payroll_industry_branch) branch
    ON cp.industry_branch_code = branch.code
    WHERE branch.name IS NOT NULL
    GROUP BY branch.name, cp.payroll_year
)
SELECT 
    branch_name,
    payroll_year,
    total_value,
    CASE 
        WHEN total_value > LAG(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year) THEN 'Growth'
        WHEN total_value < LAG(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year) THEN 'Decline'
        ELSE '-'
    END AS Trend_of_wages
FROM total_wages
ORDER BY branch_name, payroll_year;
;

SELECT *
FROM v_trend_of_wages
;

/*
 * Mzdy v průběhu let klesaly převážně v letech 2013 a 2021 a to ve všech odvětvích.
 */
SELECT *
FROM v_trend_of_wages v
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON v.branch_name = cpib."name"
WHERE v.trend_of_wages  = 'Decline'
ORDER BY v.payroll_year
;

-- Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_price_bread_milk AS -- pouze ceny mléka a chleba, bez údajů mezd
SELECT  cpc.name AS product_name,
		date_part('year',cp.date_from) AS date,
		round(avg(cp.value::numeric),2) AS avg_value,
		cpc.price_value,
		cpc.price_unit
FROM 
 (SELECT category_code,
 		value,
 		date_from,
 		date_to
	FROM czechia_price) cp
LEFT JOIN 
	(SELECT code,
			name,
			price_value,
			price_unit
	FROM czechia_price_category
	) cpc
ON cp.category_code = cpc.code
WHERE lower(name) LIKE 'chléb%'
	OR lower(name) LIKE 'mléko%'
	AND name IS NOT NULL
GROUP BY cpc.name,
		 date_part('year',cp.date_from),
		 cpc.price_value,
		 cpc.price_unit
ORDER BY name, date
;

SELECT *
FROM v_price_bread_milk


CREATE OR REPLACE VIEW v_purchasing_power_branches AS  -- kupní síla za dané odvětví (branch)
SELECT  wage.payroll_year AS year,
		wage.branch_name,
		wage.total_value,
		wage.trend_of_wages,
		price.product_name,
		price.avg_value,
		round(wage.total_value::numeric/price.avg_value::NUMERIC,2) AS purchasing_power
FROM
	(SELECT branch_name,
			payroll_year,
			total_value,
			trend_of_wages
	FROM v_trend_of_wages) wage
LEFT JOIN  
	(SELECT product_name,
			date,
			avg_value
	FROM v_price_bread_milk
	WHERE product_name IS NOT NULL
	AND date IN (2006,2018)) price
 ON wage.payroll_year = price."date"
;

CREATE OR REPLACE VIEW v_purchasing_power_final AS -- odpověď na otázku č. 2
SELECT YEAR,
		product_name,
		round(sum(total_value::numeric)/avg_value::NUMERIC,2) AS purchasing_power
FROM v_purchasing_power_branches
WHERE YEAR IN ('2006','2018')
	AND product_name IN ('Mléko polotučné pasterované','Chléb konzumní kmínový')
GROUP BY year, 
		product_name,
		avg_value	
;

SELECT *
FROM v_purchasing_power_final

SELECT *
FROM v_purchasing_power_branches



-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH basic_table as
(SELECT cpc.name AS product_name,
		date_part('year',cp.date_from) AS year,
		round(avg(cp.value::numeric),2) AS avg_value 
FROM 
 (SELECT category_code,
 		value,
 		date_from,
 		date_to
	FROM czechia_price) cp
LEFT JOIN 
	(SELECT code,
			name,
			price_value,
			price_unit
	FROM czechia_price_category
	) cpc
ON cp.category_code = cpc.code
WHERE name IS NOT NULL
GROUP BY cpc.name,
		date_part('year',cp.date_from)
ORDER BY name, YEAR)
SELECT product_name,
		YEAR,
		avg_value,
		LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR) AS previous_avg_value,
		round(((avg_value::numeric - LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR))/LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR))*100,2) AS percentage_increase
FROM basic_table 
GROUP BY product_name,
		YEAR,
		avg_value
ORDER BY percentage_increase 
LIMIT 1
;


-- Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? 

CREATE OR REPLACE VIEW v_value_of_products as
WITH basic_table as
(SELECT cpc.name AS product_name,
		date_part('year',cp.date_from) AS year,
		round(avg(cp.value::numeric),2) AS avg_value 
FROM 
 (SELECT category_code,
 		value,
 		date_from,
 		date_to
	FROM czechia_price) cp
LEFT JOIN 
	(SELECT code,
			name,
			price_value,
			price_unit
	FROM czechia_price_category
	) cpc
ON cp.category_code = cpc.code
WHERE name IS NOT NULL
GROUP BY cpc.name,
		date_part('year',cp.date_from)
ORDER BY name, YEAR)
SELECT product_name,
		YEAR,
		avg_value,
		LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR) AS previous_avg_value,
		round(((avg_value::numeric - LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR))/LAG (avg_value)OVER (PARTITION BY product_name ORDER BY YEAR))*100,2) AS percentage_increase
FROM basic_table 
GROUP BY product_name,
		YEAR,
		avg_value
ORDER BY product_name, year
;

SELECT *
FROM v_value_of_products
;

CREATE OR REPLACE VIEW v_percentage_increase_of_wages AS -- zvlášť VIEW s údaji o platech
SELECT branch_name,
		payroll_year,
		total_value,
		lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year) AS previous_total_value,
		round(((total_value::numeric - lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year))/lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year)) * 100,2) AS percentage_increase_of_wages
FROM v_trend_of_wages
WHERE payroll_year >= 2006 AND payroll_year <=2018
;

SELECT *
FROM v_percentage_increase_of_wages
;

CREATE OR REPLACE VIEW v_percentage_increase_of_wages_by_years as
SELECT payroll_year,																-- průmerný meziroční nárůst mezd, seskupeno dle let
	   round(avg(total_value),2) AS avg_total_value_of_wages,
	   round(avg(previous_total_value),2) AS avg_prev_total_value_of_wages,
	   round(avg(percentage_increase_of_wages),2) AS avg_percentage_increase_of_wages
FROM v_percentage_increase_of_wages
GROUP BY payroll_year
;

CREATE OR REPLACE VIEW v_percentage_increase_of_products_by_years as
SELECT year,																		-- průměrný meziroční nárůst potravin, seskupeno dle let
	   round(avg(avg_value),2) AS avg_total_value_of_products,
	   round(avg(previous_avg_value),2) AS avg_prev_total_value_of_products,
	   round(avg(percentage_increase),2) AS avg_percentage_increase_of_products
FROM v_value_of_products
GROUP BY year
;

SELECT *,																			-- odpověď na otázku, neexistuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd 
	   products.avg_percentage_increase_of_products - wages.avg_percentage_increase_of_wages AS diff
FROM v_percentage_increase_of_wages_by_years wages
LEFT JOIN v_percentage_increase_of_products_by_years products
ON wages.payroll_year = products.year


/*
 * Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 */

SELECT country,
		YEAR,
		gdp,
		lag(gdp)OVER (ORDER BY year) AS previous_gdp,
		round((gdp::NUMERIC - lag(gdp)OVER (ORDER BY year))/lag(gdp)OVER (ORDER BY year)*100, 2) AS percentage_increase_of_gdp
FROM economies e 
WHERE country = 'Czech Republic'
 AND gdp IS NOT NULL
 AND YEAR >= 2006 AND year <=2018
ORDER BY YEAR 






