CREATE OR REPLACE VIEW v_price_bread_milk AS 
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

CREATE OR REPLACE VIEW v_purchasing_power_branches AS  
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

