SELECT *
FROM t_monika_vymetalikova_project_SQL_primary_final

CREATE OR REPLACE VIEW v_percentage_increase_of_wages AS
WITH
  total_wages AS (
    SELECT
      branch.name AS branch_name,
      cp.payroll_year,
      sum(cp.value) AS total_value
    FROM
      (
        SELECT
          industry_branch_code,
          payroll_year,
          value
        FROM
          czechia_payroll
        WHERE
          value_type_code != 316) cp
      LEFT JOIN (
        SELECT
          name,
          code
        FROM
          czechia_payroll_industry_branch) branch 
    ON cp.industry_branch_code = branch.code
    WHERE
      branch.name IS NOT NULL
      AND payroll_year BETWEEN 2006 AND 2018
    GROUP BY
      branch.name,
      cp.payroll_year
  )
SELECT
  branch_name,
  payroll_year,
  total_value,
  lag(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year) AS previous_total_value,
  round(
    CASE
      WHEN lag(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year) IS NULL THEN NULL
      ELSE (
        (total_value::numeric - lag(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year)
        ) / lag(total_value) OVER (PARTITION BY branch_name ORDER BY payroll_year)) * 100 END, 2) AS percentage_increase_of_wages
FROM
  total_wages
ORDER BY
  branch_name,
  payroll_year
;

CREATE OR REPLACE VIEW v_value_of_products AS
WITH
  basic_table AS (
    SELECT
      cpc.name AS product_name,
      date_part('year', cp.date_from) AS year,
      round(avg(cp.value::numeric), 2) AS avg_value
    FROM
      (	  
      	SELECT
          category_code,
          value,
          date_from,
          date_to
        FROM
          czechia_price) cp
      LEFT JOIN (
        SELECT
          code,
          name,
          price_value,
          price_unit
        FROM
          czechia_price_category) cpc 
    ON cp.category_code = cpc.code
    WHERE
      name IS NOT NULL
    GROUP BY
      cpc.name,
      date_part('year', cp.date_from)
    ORDER BY
      name,
      year
  )
SELECT
  product_name,
  year,
  avg_value,
  lag(avg_value) OVER (PARTITION BY product_name ORDER BY year) AS previous_avg_value,
  round(((avg_value::numeric - lag(avg_value) OVER (PARTITION BY product_name ORDER BY YEAR)) / lag(avg_value) OVER (PARTITION BY product_name ORDER BY year)) * 100,2) AS percentage_increase
FROM
  basic_table
GROUP BY
  product_name,
  year,
  avg_value
ORDER BY
  product_name,
  year
;

CREATE TABLE t_monika_vymetalikova_project_SQL_primary_final AS
SELECT products.year,
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
ON wages.payroll_year=products.year
;

