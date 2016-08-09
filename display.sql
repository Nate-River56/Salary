SELECT 
  cpn.business      AS '業種ID',
  cpn.name          AS '会社名',
  member            AS '従業員数',
  ave_age           AS '平均年齢',
  ave_annual_income AS '平均年収(万円)'
FROM
  salary_2016
INNER JOIN
(
  SELECT 
    company.id    AS id,
    company.name  AS name,
    business.id AS business
  FROM
    company
  INNER JOIN
    business
  ON
    company.business_id = business.id
) cpn
ON
  salary_2016.company_id = cpn.id;
