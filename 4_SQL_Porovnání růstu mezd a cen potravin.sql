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

CREATE OR REPLACE VIEW v_percentage_increase_of_wages AS 
SELECT branch_name,
		payroll_year,
		total_value,
		lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year) AS previous_total_value,
		round(((total_value::numeric - lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year))/lag(total_value)OVER (PARTITION BY branch_name ORDER BY payroll_year)) * 100,2) AS percentage_increase_of_wages
FROM v_trend_of_wages
WHERE payroll_year >= 2006 AND payroll_year <=2018
;

CREATE OR REPLACE VIEW v_percentage_increase_of_wages_by_years as
SELECT payroll_year,																
	   round(avg(total_value),2) AS avg_total_value_of_wages,
	   round(avg(previous_total_value),2) AS avg_prev_total_value_of_wages,
	   round(avg(percentage_increase_of_wages),2) AS avg_percentage_increase_of_wages
FROM v_percentage_increase_of_wages
GROUP BY payroll_year
;

CREATE OR REPLACE VIEW v_percentage_increase_of_products_by_years as
SELECT year,																		
	   round(avg(avg_value),2) AS avg_total_value_of_products,
	   round(avg(previous_avg_value),2) AS avg_prev_total_value_of_products,
	   round(avg(percentage_increase),2) AS avg_percentage_increase_of_products
FROM v_value_of_products
GROUP BY year
;

SELECT *,																			
	   products.avg_percentage_increase_of_products - wages.avg_percentage_increase_of_wages AS diff
FROM v_percentage_increase_of_wages_by_years wages
LEFT JOIN v_percentage_increase_of_products_by_years products
ON wages.payroll_year = products.YEAR
;