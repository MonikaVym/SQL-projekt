**Projekt SQL - Dostupnost základních potravin široké veřejnosti v letech 2006 - 2018**



Cílem projektu je porovnat dostupnost základních potravin na základě průměrných příjmů v letech 2006 - 2018. Projekt obsahuje rozsáhlý datový podklad s informacemi o vývoji mezd v daných odvětvích a vývoj cen základních potravin. Primárním úkolem bylo sjednotit data dle let, zjistit průměr mezd, procentuální vývoj mezd i cen potravin a tato data mezi sebou porovnat.

Projekt obsahuje tabulku t\_monika\_vymetalikova\_project\_SQL\_primary\_final.sql,která umožňuje porovnávat vývoj mezd podle odvětví s vývojem cen produktů v letech 2006-2018 a dodatečnou tabulku t\_monika\_vymetalikova\_project\_SQL\_secondary\_final.sql, kde jsou obsaženy ekonomická data (HDP, počet obyvatel, Giniho index) pro evropské země mimo Českou republiku.

V projektu byly používány převážně dotazy obsahující klauzule WHERE, ORDER BY, LIMIT,GROUP BY, agregační funkce, CASE EXPRESSION, WINDOW FUNCTIONS, COMMON TABLE EXPRESSION (CTE) a jiné.



Tabulka t\_monika\_vymetalikova\_project\_SQL\_primary\_final.sql je vytvořena pomocí dvou VIEW. První VIEW v\_percentage\_increase\_of\_wages umožňuje kdykoliv jednoduše zjistit meziroční nárůst celkové hodnoty mezd v jednotlivých odvětvích v České republice, mezi lety 2006 - 2018. Pomocí CTE total\_wages byl ze zdrojových tabulek czechia\_payroll a czechia\_industry\_branch vytvořen agregovaný přehled mezd podle odvětví a let. Důležitým krokem bylo vyloučení některých typu hodnot (value\_type\_code !=316, tzn. Průměrný počet zaměstnaných osob), která jsou pro analýzu nepotřebná. Pomocí agregační funkce SUM byl zjištěn celkový objem mezd v daném odvětví a roce. Z CTE total\_wages byl pomocí implementace funkce LAG zjištěn procentní nárůst mezd (percentage\_increase\_of\_wages). Data jsou seřazena podle názvu odvětví a let.

Druhé VIEW v\_value\_of\_products sleduje vývoj průměrných cen produktů v České republice v daných letech, včetně toho, o kolik procent se meziročně změnila jejich průměrná cena. CTE basic\_table připravuje pomocí zdrojových tabulek czechia\_price a czechia\_price\_category základní data - název produktu, rok a průměrnou cenu produktu. Jsou vybrány pouze záznamy, kde existuje název produktu (name IS NOT NULL). Z výsledné basic\_table se vytváří finální VIEW. Pomocí funkce LAG získáváme údaj z předchozího roku a vypočítáme procentuální změnu vývoje ceny produktu (((současná\_hodnota - předchozí\_hodnota) / předchozí\_hodnota) \* 100) zaokrouhlenou na 2 desetinná místa. Dotaz je agregován pomocí GROUP BY a přehledně seřazen dle názvu produktu a let.

Využitím funkce JOIN a spojením těchto vytvořených VIEW na základě let (payroll\_year = year) je vytvořená tabulka t\_monika\_vymetalikova\_project\_SQL\_primary\_final.sql. 

Tato tabulka je základem pro zodpovězení výzkumných otázek



Sekundární tabulka t\_monika\_vymetalikova\_project\_SQL\_secondary.final.sql. je vytvořena spojením dvou zdrojových tabulek countries a economies.

Pro zachování informací o všech evropských zemích, i těch, pro které může ekonomická informace chybět byla použita fce LEFT JOIN.



**Výzkumné otázky:**

*1.  Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*

V průběhu sledovaných let některá odvětví značí významnější růst oproti jiným, např. Peněžnictví a pojišťovnictví nebo Stavebnictví. Ovšem i tato odvětví zaznamenala pokles a to v roce 2013. Nejčastější pokles mezd vidíme v odvětví Těžba a dobývání. Zde došlo k poklesu v letech 2009, 2013, 2014 a 2016. K odvětvím, kde zaznamenáváme růst patří Zpracovatelský průmysl, Doprava a skladování, Zdravotní a sociální péče a Ostatní činnosti.

1\_SQL\_Trend\_of\_wages.sql: 

Využitím CASE EXPRESSION se porovnává aktuální hodnota mezd s hodnotou z předchozího roku (fce LAG). Výsledkem je sloupec trend\_of\_wages, který obsahuje informaci, zda vývoj mezd v daném odvětví meziročně rostl (Growth), klesl (Decline) nebo stagnoval (Stagnation). V roce 2006 tento údaj chybí (-) jelikož neznáme hodnotu z předchozího roku (2005).



*2.  Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?*

V roce 2006 je možné koupit 218 460,87 litrů polotučného pasterovaného mléka a 195 693, 24 kg konzumního kmínového chleba.

V roce 2018 bylo možné koupit 249 518, 16 litrů polotučného pasterovaného mléka a 204 020, 21 kg konzumního kmínového chleba.

2\_SQL\_Purchasing\_Power\_of\_Milk\_and\_Bread.sql: 

Pomocí agregační funkce byla vypočítaná kupní síla. Ta byla zaokrouhlena a 2 desetinná místa (round(sum(total\_value::numeric) / avg\_value::numeric, 2)). Klauzulí WHERE IN byly vybrány produkt a roky u kterých kupní sílu zjišťujeme.



*3.  Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*

V roce 2007 došlo u potraviny Rajská jablka červená naopak k poklesu o -30,28%, což znamená výrazné snížení ceny ve srovnání s ostatními kategoriemi.

3\_SQL\_Food\_with\_the\_Lowest\_Price\_Growth.sql:

Zde byl primárním postupem správný výběr (year, product\_name, percentage\_incrase) a seřazení dat. Následně pomocí funkce LIMIT výběr produktu s nejnižším procentuálním růstem (poklesem).



*4.  Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*

Analyzováním sloupce "diff" lze identifikovat roky, kdy růst cen potravin přesáhl 10 % oproti růstu mezd. Například v roce 2009 činil tento rozdíl 9,56 %, což naznačuje, že ceny potravin rostly výrazně rychleji než mzdy v tomto období. Podobně v roce 2018 byl rozdíl 5,37 %, což ukazuje na další rok, kdy ceny potravin překonaly růst mezd, avšak ne o více než 10 %.

4\_SQL\_Trend\_in\_Wage\_Groth\_vs\_Food\_Prices.sql:

Zde byl zjišťován průměrný meziroční procentuální nárůst mezd (avg\_percentage\_increase\_of\_wages) a průměrný meziroční procentuální nárůst cen produktů (avg\_percentage\_increase\_of\_products). Rozdíl mezi nárůstem cen a nárůstem mezd znázorňuje sloupec diff. Pokud jsou hodnoty v tomto sloupci kladné, ceny rostly víc než mzdy, pokud záporné mzdy rostly víc než ceny.



*5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*

Analýza zahrnuje roky 2007 - 2018 a ukazuje, jak se měnila ekonomika České republiky. V roce 2007 můžeme vidět nejvyšší meziroční nárůst HDP (5,57%), kdy v tomto roce významně rostla výše mezd (6,91%), ale i ceny potravin (9,26%). Naopak v roce 2009 data ukazují pokles HDP (-4,66%) a s tím spojený nižší nárůst mezd (2,97%) a snížení cen potravin (6,59%). Zajímavý je rok 2013, kdy došlo k meziročnímu poklesu HDP (-0,05%), zároveň k poklesu vývoji mezd (-0,78%), ale významně vyššímu nárůstu cen potravin (6,01%).

5\_SQL\_GDP\_Impact\_on\_Wages\_and\_Products.sql:

Vnořený SELECT vypočítá meziroční procentuální nárůst HDP České republiky (percentage\_increase\_of\_gdp). Využívá funkci LAG k porovnání aktuálního roku s předchozím. Tato data jsou získaná se zdrojové tabulky economies. Připojením (JOIN)tabulky  t\_monika\_vymetalikova\_project\_SQL\_primary\_final.sql (prim\_table.year=ecomies.year) zjistíme průměrný procentuální meziroční nárůst mezd a průměrný procentuální meziroční nárůst produktů. 











