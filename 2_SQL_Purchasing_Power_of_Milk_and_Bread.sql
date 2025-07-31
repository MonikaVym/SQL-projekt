SELECT
  year,
  product_name,
  round(sum(total_value::numeric) / avg_value::numeric, 2) AS purchasing_power
FROM
  t_monika_vymetalikova_project_sql_primary_final
WHERE
  year IN ('2006', '2018')
  AND product_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY
  year,
  product_name,
  avg_value
ORDER BY
  year
;