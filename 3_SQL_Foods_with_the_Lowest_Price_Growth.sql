SELECT DISTINCT
  year,
  product_name,
  percentage_increase
FROM
  t_monika_vymetalikova_project_sql_primary_final
ORDER BY
  percentage_increase
LIMIT
  1
;