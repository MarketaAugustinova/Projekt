SELECT *
FROM platy_a_ceny pac;

--vypocet procenta zvyseni ceny
SELECT rok, potravina, cena_dalsi_rok/prum_cena*100 - 100 AS navyseni
FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena;

--vypocet procenta zvyseni ceny
SELECT rok +1 AS srovnavany_rok, potravina, cena_dalsi_rok/prum_cena*100 - 100 AS navyseni
FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena;

--zaokrouhleni
SELECT rok +1, potravina, round(cena_dalsi_rok/prum_cena*100 - 100 ::NUMERIC,0) AS navyseni
FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena;

--serazeni
SELECT rok, potravina, round(cena_dalsi_rok/prum_cena*100 - 100 ::NUMERIC,0) AS navyseni
FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena
ORDER BY navyseni;

--serazeni a urceni vzrustu
SELECT rok +1, potravina, round(cena_dalsi_rok/prum_cena*100 - 100 ::NUMERIC,0) AS navyseni, 
	CASE 
		WHEN  (cena_dalsi_rok/prum_cena*100 - 100) > 0 THEN 'zdrazeni'
		ELSE 'zlevneni' END AS kvalifikace 
	FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena
ORDER BY navyseni;

--pohled zdrazeni/zlevneni 
CREATE VIEW zdrazeni AS 
SELECT rok +1 AS hodnoceny_rok, potravina, round(cena_dalsi_rok/prum_cena*100 - 100 ::NUMERIC,0) AS procento_navyseni, 
	CASE 
		WHEN  (cena_dalsi_rok/prum_cena*100 - 100) > 0 THEN 'zdrazeni'
		ELSE 'zlevneni' END AS kvalifikace 
	FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena
ORDER BY procento_navyseni; 

SELECT *
FROM zdrazeni z; 

--nejmene zdrazovane potraviny
SELECT potravina, COUNT(kvalifikace)
FROM zdrazeni z
GROUP BY potravina, kvalifikace   
HAVING kvalifikace = 'zlevneni'
ORDER BY COUNT desc;

--nejvice zdrazovane potraviny
SELECT potravina, COUNT(kvalifikace)
FROM zdrazeni z
GROUP BY potravina, kvalifikace   
HAVING kvalifikace = 'zdrazeni'
ORDER BY count desc;

--roky se zdrazenim

SELECT hodnoceny_rok, COUNT(kvalifikace)
FROM zdrazeni z
GROUP BY hodnoceny_rok, kvalifikace   
HAVING kvalifikace = 'zdrazeni'
ORDER BY count desc; 

--zdrazeni nad 10 %
SELECT rok +1 AS hodnoceny_rok, potravina, round(cena_dalsi_rok/prum_cena*100 - 100 ::NUMERIC,0) AS procento_navyseni, 
	CASE 
		WHEN  (cena_dalsi_rok/prum_cena*100 - 100) > 10 THEN 'zdrazeni_nad_10_procent'
		WHEN  (cena_dalsi_rok/prum_cena*100 - 100) > 0 THEN 'zdrazeni'
		ELSE 'zlevneni' END AS kvalifikace 
	FROM platy_a_ceny pac
GROUP BY rok, potravina, cena_dalsi_rok, prum_cena; 

--prumerne zdrazeni vsech potravin
SELECT hodnoceny_rok, round (AVG(procento_navyseni)::NUMERIC, 1) AS prum_zdrazeni_vsech_potravin
FROM zdrazeni z 
GROUP BY hodnoceny_rok

--se mzdama
SELECT hodnoceny_rok, round (AVG(procento_navyseni)::NUMERIC, 1) AS prum_zdrazeni_vsech_potravin
FROM zdrazeni z 
GROUP BY hodnoceny_rok
ORDER BY prum_zdrazeni_vsech_potravin ; 

--kopie ze scriptu 27 radek 37
SELECT pac.industry_branch_code, 
		pac.rok, pac.prum_mzda_v_odvetvi, 
		pac2.rok, pac2.prum_mzda_v_odvetvi
FROM platy_a_ceny pac  
JOIN platy_a_ceny pac2  
	ON pac.industry_branch_code = pac2.industry_branch_code 
		AND pac.rok = pac2.rok - 1; 

--procento rozdilu mezd z pac
--kopie ze scriptu 27 radek 37
SELECT pac.industry_branch_code, 
		pac.rok, pac.prum_mzda_v_odvetvi, 
		pac2.rok, pac2.prum_mzda_v_odvetvi AS pr_mzda_dalsi_rok, 
		round((pac2.prum_mzda_v_odvetvi/pac.prum_mzda_v_odvetvi*100 - 100)::NUMERIC,2 ) AS procento_zvyseni_mzdy
FROM platy_a_ceny pac  
JOIN platy_a_ceny pac2  
	ON pac.industry_branch_code = pac2.industry_branch_code 
		AND pac.rok = pac2.rok - 1;

--procento rozdilu mezd z pac
--kopie ze scriptu 27 radek 37
SELECT pac.industry_branch_code, 
		pac.rok, pac.prum_mzda_v_odvetvi, 
		pac2.rok, pac2.prum_mzda_v_odvetvi AS pr_mzda_dalsi_rok, 
		round((pac2.prum_mzda_v_odvetvi/pac.prum_mzda_v_odvetvi*100 - 100)::NUMERIC,2 ) AS procento_zvyseni_mzdy
FROM platy_a_ceny pac  
JOIN platy_a_ceny pac2  
	ON pac.industry_branch_code = pac2.industry_branch_code 
		AND pac.rok = pac2.rok - 1
GROUP BY pac.industry_branch_code, pac.rok, pac.prum_mzda_v_odvetvi, pac2.rok, pac2.prum_mzda_v_odvetvi;

---pr. mzdy ve vsech odvetvi
SELECT rok, round(AVG(prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_celkem
FROM platy_a_ceny pac 
GROUP BY rok; 

---pr. mzdy ve vsech odvetvi 2 roky po sobe
SELECT pac.rok, round(AVG(pac.prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_celkem, 
		pac2.rok, round(AVG(pac2.prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_celkem_2
FROM platy_a_ceny pac 
JOIN platy_a_ceny pac2 ON pac.rok = pac2.rok - 1
GROUP BY pac.rok, pac2.rok;


---podil a procento
SELECT pac.rok, round(AVG(pac.prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_celkem, 
		pac2.rok, round(AVG(pac2.prum_mzda_v_odvetvi)::NUMERIC,2) AS prum_mzda_celkem_2,
		round(AVG(pac2.prum_mzda_v_odvetvi)/AVG(pac.prum_mzda_v_odvetvi)::NUMERIC,2)*100 -100 AS procento_vzrustu
FROM platy_a_ceny pac 
JOIN platy_a_ceny pac2 ON pac.rok = pac2.rok - 1
GROUP BY pac.rok, pac2.rok
ORDER BY procento_vzrustu desc;





