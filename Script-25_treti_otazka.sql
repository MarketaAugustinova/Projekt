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




