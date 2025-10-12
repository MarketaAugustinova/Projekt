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

-- prumerne mzdy po letech vsechna odvetvi dohromady:
SELECT payroll_year, round (AVG(prum_mzda_v_odvetvi)::NUMERIC,2)
FROM prumerne_mzdy_srov_roky pmsr 
GROUP BY payroll_year 
ORDER BY payroll_year; 

-- mzdy v nasl. dvou letech v jedn. odvetvich 
SELECT pmsr.industry_branch_code, 
		pmsr.payroll_year, pmsr.prum_mzda_v_odvetvi, 
		pmsr2.payroll_year, pmsr2.prum_mzda_v_odvetvi
FROM prumerne_mzdy_srov_roky pmsr 
JOIN prumerne_mzdy_srov_roky pmsr2 
	ON pmsr.industry_branch_code = pmsr2.industry_branch_code 
		AND pmsr.payroll_year = pmsr2.payroll_year - 1; 

--rozdil mezd
SELECT pmsr.industry_branch_code, 
		pmsr.payroll_year, pmsr.prum_mzda_v_odvetvi, 
		pmsr2.payroll_year, pmsr2.prum_mzda_v_odvetvi,
		pmsr2.prum_mzda_v_odvetvi - pmsr.prum_mzda_v_odvetvi AS rozdil_mezd
FROM prumerne_mzdy_srov_roky pmsr 
JOIN prumerne_mzdy_srov_roky pmsr2 
	ON pmsr.industry_branch_code = pmsr2.industry_branch_code 
		AND pmsr.payroll_year = pmsr2.payroll_year - 1; 

CREATE VIEW rozdil_mezd_srov_roky AS 
SELECT pmsr.industry_branch_code, 
		pmsr.payroll_year AS rok, pmsr.prum_mzda_v_odvetvi AS mzda_prvni_rok, 
		pmsr2.payroll_year AS dalsi_rok, pmsr2.prum_mzda_v_odvetvi AS mzda_dalsi_rok,
		pmsr2.prum_mzda_v_odvetvi - pmsr.prum_mzda_v_odvetvi AS rozdil_mezd
		FROM prumerne_mzdy_srov_roky pmsr 
JOIN prumerne_mzdy_srov_roky pmsr2 
	ON pmsr.industry_branch_code = pmsr2.industry_branch_code 
		AND pmsr.payroll_year = pmsr2.payroll_year - 1; 

--zjisteni pokles/vzestup mezd
SELECT industry_branch_code, rok, dalsi_rok, rozdil_mezd,
	CASE WHEN rozdil_mezd > 0 THEN 'vzestup' ELSE 'pokles' 
		END AS zmena_mzdy
FROM rozdil_mezd_srov_roky rmsr;

-- pripojeni nazvu odvetvi
SELECT rmsr.industry_branch_code, cpib."name", rmsr.rok, rmsr.dalsi_rok, rmsr.rozdil_mezd,
	CASE WHEN rozdil_mezd > 0 THEN 'vzestup' ELSE 'pokles' 
		END AS zmena_mzdy
FROM rozdil_mezd_srov_roky rmsr
	JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = rmsr.industry_branch_code; 

--vysledna tabulka
CREATE TABLE zmeny_mezd AS 
	SELECT rmsr.industry_branch_code, cpib."name", rmsr.rok, rmsr.dalsi_rok, rmsr.rozdil_mezd,
	CASE WHEN rozdil_mezd > 0 THEN 'vzestup' ELSE 'pokles' 
		END AS zmena_mzdy
FROM rozdil_mezd_srov_roky rmsr
	JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = rmsr.industry_branch_code; 

--dotaz na pokles mzdy
SELECT *
FROM zmeny_mezd zm
WHERE zmena_mzdy = 'pokles' 
ORDER BY industry_branch_code ; 

--dotaz na odvetvi s poklesem mzdy
SELECT DISTINCT name
FROM zmeny_mezd zm 
WHERE name IN (SELECT name
				FROM zmeny_mezd zm 
				WHERE zmena_mzdy = 'pokles' 
				ORDER BY industry_branch_code);


--dotaz na odvetvi bez poklesu mzdy
SELECT DISTINCT name 
FROM zmeny_mezd zm 
WHERE name NOT IN (SELECT name
FROM zmeny_mezd zm 
WHERE zmena_mzdy = 'pokles' 
ORDER BY industry_branch_code ); 

--dotaz na cetnost poklesu mezd v jedn. odvetvi
SELECT name, count (zmena_mzdy) AS pocet_let
FROM zmeny_mezd zm
GROUP BY name, zmena_mzdy 
HAVING zmena_mzdy = 'pokles'; 

--dotaz na rok s poklesem mezd v nejvice odvetvich 
SELECT dalsi_rok, count (zmena_mzdy) AS pocet_odvetvi
FROM zmeny_mezd zm
GROUP BY dalsi_rok, zmena_mzdy 
HAVING zmena_mzdy = 'pokles'
ORDER BY dalsi_rok ; 





