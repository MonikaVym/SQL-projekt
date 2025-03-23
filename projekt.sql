
-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

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

/*
 * Mzdy v průběhu let klesaly ve všech odvětvích. category A-S
 */
SELECT *
FROM v_trend_of_wages v
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON v.branch_name = cpib."name"
WHERE v.trend_of_wages  = 'Decline'
ORDER BY cpib.code
;



--Otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_price_bread_milk AS -- pouze ceny mléka a chleba, bez údajů mezd
SELECT cpc.name AS product_name,
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



CREATE OR REPLACE VIEW v_purchasing_power_branches AS  -- kupní síla za dané odvětví (branch)
SELECT wage.payroll_year AS year,
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

CREATE OR REPLACE VIEW v_purchasing_power_final as
SELECT YEAR,
		product_name,
		round(sum(total_value::numeric)/avg_value::NUMERIC,2) AS purchasing_power
FROM v_purchasing_power_bread_milk
WHERE YEAR IN ('2006','2018')
	AND product_name IN ('Mléko polotučné pasterované','Chléb konzumní kmínový')
GROUP BY year, 
		product_name,
		avg_value
;

SELECT *
FROM v_purchasing_power_final





