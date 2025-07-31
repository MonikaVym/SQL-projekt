SELECT
  year,
  round(avg(percentage_increase_of_wages), 2) AS avg_percentage_increase_of_wages,
  round(avg(percentage_increase), 2) AS avg_percentage_increase_of_products,
  round(avg(percentage_increase), 2) - round(avg(percentage_increase_of_wages), 2) AS diff
FROM
  t_monika_vymetalikova_project_sql_primary_final
GROUP BY
  year
ORDER BY
  year
;

