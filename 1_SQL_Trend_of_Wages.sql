SELECT
  year,
  branch_name,
  total_value,
  CASE
    WHEN total_value > lag(total_value) OVER (PARTITION BY branch_name ORDER BY year) THEN 'Growth'
    WHEN total_value < lag(total_value) OVER (PARTITION BY branch_name ORDER BY year) THEN 'Decline'
    WHEN total_value = lag(total_value) OVER (PARTITION BY branch_name ORDER BY year) THEN 'Stagnation'
    ELSE '-'
  END AS Trend_of_wages
FROM
  t_monika_vymetalikova_project_SQL_primary_final
GROUP BY
  year,
  branch_name,
  total_value
ORDER BY
  year,
  branch_name ASC
;