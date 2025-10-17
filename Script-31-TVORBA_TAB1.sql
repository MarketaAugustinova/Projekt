---vypocet prum. mezd ve srov. obdobi
-- jen roky 2006 az 2008
CREATE VIEW prumerne_mzdy_srov_roky AS 
SELECT payroll_year, industry_branch_code, avg(value) AS prum_mzda_v_odvetvi 
FROM czechia_payroll cp
WHERE value_type_code = 5958 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year
ORDER BY payroll_year, industry_branch_code; 

--tvorba pohledu prum_ceny
CREATE VIEW prum_ceny AS 
SELECT date_part('year', date_from) AS rok, category_code, 
		round(avg(value)::NUMERIC,2) AS prum_cena
FROM czechia_price cp 
GROUP BY rok, category_code 
ORDER BY rok;  

--Tvorba pohledu 'platy_a_ceny'
CREATE VIEW platy_a_ceny AS 
	SELECT pc.rok, industry_branch_code, round (prum_mzda_v_odvetvi::NUMERIC,2) AS prum_mzda_v_odvetvi, 
		name AS potravina, pc.prum_cena, pc2.prum_cena AS cena_dalsi_rok, 
		round ((prum_mzda_v_odvetvi/pc.prum_cena)::NUMERIC,2) AS pocet_produktu_za_mzdu
	FROM prumerne_mzdy_srov_roky pmsr 
	JOIN prum_ceny pc ON pmsr.payroll_year = pc.rok 
	JOIN prum_ceny pc2 ON pc.rok = pc2.rok - 1 
					AND pc.category_code = pc2.category_code	
	JOIN czechia_price_category cpc ON pc.category_code = cpc.code
	GROUP BY pc.rok, industry_branch_code, pmsr.prum_mzda_v_odvetvi, name, pc.prum_cena, pc2.prum_cena;