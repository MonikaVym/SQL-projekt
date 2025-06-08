SELECT economies.YEAR,
		economies.percentage_increase_of_gdp,
		wages_and_products.avg_percentage_increase_of_wages,
		wages_and_products.avg_percentage_increase_of_products
FROM
	(SELECT YEAR,
			gdp,
			lag(gdp)OVER (ORDER BY year) AS previous_gdp,
			round (((gdp::NUMERIC - lag(gdp::numeric)OVER (ORDER BY year))/lag(gdp::numeric)OVER (ORDER BY year)) * 100,2) AS percentage_increase_of_gdp
	FROM economies
	WHERE country = 'Czech Republic'
 	AND gdp IS NOT NULL
 	AND YEAR >= 2006 AND year <=2018
	ORDER BY YEAR) economies
LEFT JOIN
	(SELECT *																		
	FROM v_percentage_increase_of_wages_by_years wages
	LEFT JOIN v_percentage_increase_of_products_by_years products
	ON wages.payroll_year = products.YEAR) wages_and_products
ON wages_and_products.payroll_year = economies.YEAR
WHERE percentage_increase_of_gdp IS NOT null
;

SELECT country,     
		YEAR,
		gdp,
		lag(gdp)OVER (ORDER BY year) AS previous_gdp,
		round (((gdp::NUMERIC - lag(gdp::numeric)OVER (ORDER BY year))/lag(gdp::numeric)OVER (ORDER BY year)) * 100,2) AS percentage_increase_of_gdp
FROM economies e 
WHERE country = 'Czech Republic'
 AND gdp IS NOT NULL
 AND YEAR >= 2006 AND year <=2018
ORDER BY YEAR
;

