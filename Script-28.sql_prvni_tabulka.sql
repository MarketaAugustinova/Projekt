CREATE VIEW prumerne_mzdy AS 
SELECT payroll_year, industry_branch_code, avg(value) AS prum_mzda_v_odvetvi 
FROM czechia_payroll cp
WHERE value_type_code = 5958
GROUP BY industry_branch_code, payroll_year
ORDER BY payroll_year, industry_branch_code;

-- jen roky 2006 az 2008
CREATE VIEW prumerne_mzdy_srov_roky AS 
SELECT payroll_year, industry_branch_code, avg(value) AS prum_mzda_v_odvetvi 
FROM czechia_payroll cp
WHERE value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year
ORDER BY payroll_year, industry_branch_code;


SELECT payroll_year, round (AVG(prum_mzda_v_odvetvi)::NUMERIC,2)
FROM prumerne_mzdy_srov_roky pmsr 
GROUP BY payroll_year 
ORDER BY payroll_year;


