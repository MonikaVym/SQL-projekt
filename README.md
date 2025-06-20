                        Projekt SQL - Dostupnost základních potravin široké veřejnosti v letech 2006 - 2018

Cílem projektu je porovnat dostupnost základních potravin na základě průměrných příjmů v letech 2006 - 2018. Projekt obsahuje rozsáhlý datový podklad s informacemi o vývoji mezd v daných odvětvích a vývoj cen základních potravin. Primárním úkolem bylo sjednotit dostupná data dle let, zjistit průměr mezd, meziroční vývoj mezd i cen potravin a tato data mezi sebou porovnat.
Projekt obsahuje tabulku t_monika_vymetalikova_project_SQL_primary_final.sql, která odpovídá na zadané výzkumné otázky a dodatečnou tabulku t_monika_vymetalikova_project_SQL_secondary_final.sql, kde jsou obsaženy informace o HDP, GINI koeficient a míra populace v dalších evropských státech.
V projektu byly používány převážně dotazy obsahující klauzule WHERE, ORDER BY, LIMIT,GROUP BY, agregační funkce, CASE EXPRESSION, WINDOW FUNCTIONS, COMMON TABLE EXPRESSION a jiné.

Výzkumné otázky:
1.  Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
V průběhu sledovaných let některá odvětví značí významnější růst oproti jiným, např. Peněžnictví a pojišťovnictví nebo Stavebnictví. Ovšem i tato odvětví zaznamenala pokles, a to v roce 2013. Nejčastější pokles mezd vidíme v odvětví Těžba a dobývání. Zde došlo k poklesu v letech 2009, 2013, 2014 a 2016. K odvětvím, kde zaznamenáváme růst patří Zpracovatelský průmysl, Doprava a skladování, Zdravotní a sociální péče a Ostatní činnosti.
1_SQL_Trend mezd.sql

3.  Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
V roce 2006 je možné koupit 218 460,87 litrů polotučného pasterovaného mléka a 195 693, 24 kg konzumního kmínového chleba.
V roce 2018 bylo možné koupit 249 518, 16 litrů polotučného pasterovaného mléka a 204 020, 21 kg konzumního kmínového chleba.
2_SQL_Cena mléka a chleba.sql

4.  Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
V roce 2007 došlo u potraviny Rajská jablka červená naopak k poklesu o -30,28%, což znamená výrazné snížení ceny ve srovnání s ostatními kategoriemi.
3_SQL_Potraviny s nejnižším cenovým růstem.sql

5.  Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Analyzováním sloupce "diff" lze identifikovat roky, kdy růst cen potravin přesáhl 10 % oproti růstu mezd. Například v roce 2009 činil tento rozdíl 9,56 %, což naznačuje, že ceny potravin rostly výrazně rychleji než mzdy v tomto období. Podobně v roce 2018 byl tento rozdíl 5,37 %, což ukazuje na další rok, kdy ceny potravin překonaly růst mezd, avšak ne o více než 10 %.
4_SQL_Porovnání růstu mezd a cen potravin.sql

6. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
Analýza zahrnuje roky 2007 - 2018 a ukazuje, jak se měnila ekonomika České republiky. V roce 2007 můžeme vidět nejvyšší meziroční nárůst HDP (5,57%), kdy v tomto roce významně rostla výše mezd (6,91%), ale i ceny potravin (9,26%). Naopak v roce 2009 data ukazují pokles HDP (-4,66%) a s tím spojený nižší nárůst mezd (2,97%) a snížení cen potravin (6,59%). Zajímavý je rok 2013, kdy došlo k meziročnímu poklesu HDP (-0,05%), zároveň k poklesu vývoji mezd (-0,78%), ale významně vyššímu nárůstu cen potravin (6,01%).
5_SQL_Vliv HDP na mzdy a ceny potravin.sql




