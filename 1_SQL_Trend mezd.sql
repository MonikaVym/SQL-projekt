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
    AND payroll_year BETWEEN 2006 AND 2018
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
FROM v_trend_of_wages v
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON v.branch_name = cpib."name"
WHERE v.trend_of_wages  = 'Decline'
ORDER BY v.payroll_year
;


