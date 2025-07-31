CREATE TABLE t_monika_vymetalikova_project_SQL_secondary_final AS
SELECT
  c.country,
  c.continent,
  e.year,
  e.gdp,
  e.population,
  e.gini
FROM
  countries c
  LEFT JOIN economies e ON c.country = e.country
WHERE
  continent = 'Europe'
  AND c.country != 'Czech Republic'
  AND YEAR BETWEEN 2006 AND 2018
ORDER BY
  country ASC,
  year ASC
;
