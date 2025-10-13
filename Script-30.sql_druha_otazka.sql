SELECT *
FROM czechia_price cp 


--uprava data, vypocet prum ceny pro jedn. kategorie
SELECT date_part('year', date_from) AS rok, category_code, round(avg(value)::NUMERIC,2)
FROM czechia_price cp 
GROUP BY rok,  cp.category_code 
ORDER BY rok; 

--tvorba pohledu prum_ceny
CREATE VIEW prum_ceny AS 
SELECT date_part('year', date_from) AS rok, category_code, 
		round(avg(value)::NUMERIC,2) AS prum_cena
FROM czechia_price cp 
GROUP BY rok, category_code 
ORDER BY rok;

--kontrola
SELECT *
FROM prum_ceny pc; 

--pridani nazvu kategorii
SELECT pc.rok, cpc.name, pc.prum_cena
FROM prum_ceny pc 
JOIN czechia_price_category cpc ON pc.category_code = cpc.code
ORDER BY rok; 

--mleko, chleba
SELECT pc.rok, cpc.name, pc.prum_cena
FROM prum_ceny pc 
JOIN czechia_price_category cpc ON pc.category_code = cpc.code
WHERE name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový' )
ORDER BY rok; 

-- mzdy a ceny vybr. potravin vse
SELECT *
FROM prumerne_mzdy_srov_roky pmsr 
JOIN prum_ceny pc ON pmsr.payroll_year = pc.rok 
JOIN czechia_price_category cpc ON pc.category_code = cpc.code
WHERE name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový' )
ORDER BY rok;

--srovnani a podil
SELECT rok, round (AVG(prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_v_roce, 
		name, prum_cena,
		round ((AVG(prum_mzda_v_odvetvi)/prum_cena)::NUMERIC,2) AS pocet_produktu
FROM prumerne_mzdy_srov_roky pmsr 
JOIN prum_ceny pc ON pmsr.payroll_year = pc.rok 
JOIN czechia_price_category cpc ON pc.category_code = cpc.code
WHERE name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový' )
GROUP BY rok, name, pc.prum_cena
ORDER BY rok;




