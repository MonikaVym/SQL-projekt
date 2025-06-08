CREATE TABLE t_monika_vymetalikova_project_SQL_primary_final as
SELECT products.YEAR,
		wages.branch_name,
		wages.total_value,
		wages.percentage_increase_of_wages,
		products.product_name,
		products.avg_value,
		products.percentage_increase
FROM (
SELECT payroll_year,
		branch_name,
		total_value,
		percentage_increase_of_wages
FROM v_percentage_increase_of_wages wages) wages
LEFT JOIN v_value_of_products products
ON wages.payroll_year=products.YEAR
;
