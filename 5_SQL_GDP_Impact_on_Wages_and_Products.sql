SELECT
  economies.year,
  economies.percentage_increase_of_gdp,
  round(avg(prim_table.percentage_increase_of_wages), 2) AS percentage_increase_of_wages,
  round(avg(prim_table.percentage_increase), 2) AS percentage_increase
FROM
  (
  	SELECT
      year,
      gdp,
      lag(gdp) OVER (ORDER BY year) AS previous_gdp,
      round(((gdp::numeric - lag(gdp::numeric) OVER (ORDER BY year)) / lag(gdp::numeric) OVER (ORDER BY year)) * 100,2) AS percentage_increase_of_gdp
    FROM
      economies
    WHERE
      country = 'Czech Republic'
      AND gdp IS NOT NULL
      AND year >= 2006
      AND year <= 2018) economies
  LEFT JOIN t_monika_vymetalikova_project_sql_primary_final prim_table 
ON prim_table.year = economies.year
WHERE
  economies.percentage_increase_of_gdp IS NOT NULL
GROUP BY
  economies.year,
  economies.percentage_increase_of_gdp
ORDER BY
  economies.YEAR
;



