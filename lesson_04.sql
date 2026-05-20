

/*
Spojování tabulek pomocí JOIN
*/



/*
 * Úkol 1: Spojte tabulky czechia_price a czechia_price_category. Vypište všechny dostupné sloupce.
 */


SELECT *
FROM czechia_price
LEFT JOIN czechia_price_category
	ON czechia_price.category_code = czechia_price_category.code; 


/*
 * Úkol 2: Předchozí příklad upravte tak, 
 * že vhodně přejmenujete tabulky a vypíšete ID a jméno kategorie potravin a cenu.
 */

SELECT
	cp.id,
	cpc.name,
	cp.value 
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc
	ON cpc.code = cp.category_code;


/*
 * Úkol 3: Přidejte k tabulce cen potravin i informaci o krajích ČR 
 * a vypište informace o cenách společně s názvem kraje.
 */


SELECT 
	cp.*,
	cr.name
FROM czechia_price cp
LEFT JOIN czechia_region cr 
	ON cr.code = cp.region_code;

-- 108 249
SELECT 
	count(*) AS total_rows
FROM czechia_price cp
LEFT JOIN czechia_region cr 
	ON cr.code = cp.region_code;

-- 101 032
SELECT 
	count(*) AS total_rows
FROM czechia_price cp
JOIN czechia_region cr 
	ON cr.code = cp.region_code;


/* 
 * Úkol 4: Využijte v příkladě z předchozího úkolu RIGHT JOIN s výměnou pořadí tabulek. 
 * Jak se změní výsledky?
 */


SELECT 
	cp.*,
	cr.name
FROM czechia_region cr 
RIGHT JOIN czechia_price cp
	ON cr.code = cp.region_code;


/*
 * Úkol 5: K tabulce czechia_payroll připojte všechny okolní tabulky. 
 * Využijte ERD model ke zjištění, které to jsou.
 */

SELECT *
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_calculation cpc
	ON cpc.code = cp.calculation_code
LEFT JOIN czechia_payroll_industry_branch cpi
	ON cpi.code = cp.industry_branch_code 
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpv
	ON cpv.code = cp.value_type_code;


-- pokracujeme 19:09



/*
 * Úkol 6: Přepište dotaz z předchozí lekce do varianty, ve které použijete JOIN,
 */


SELECT
    *
FROM czechia_payroll_industry_branch
WHERE code IN (
    SELECT
        industry_branch_code
    FROM czechia_payroll
    WHERE value IN (
        SELECT
            max(value)
        FROM czechia_payroll
        WHERE value_type_code = 5958
    )
);


SELECT
	cpib.*
FROM czechia_payroll_industry_branch cpib
LEFT JOIN czechia_payroll cp 
	ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = 5958
ORDER BY cp.value DESC
LIMIT 1;


/*
 * Úkol 7: Spojte informace z tabulek cen a mezd (pouze informace o průměrných mzdách). 
 * Vypište z každé z nich základní informace, celé názvy odvětví a kategorií potravin a datumy měření, 
 * které vhodně naformátujete.
*/


SELECT
	cpc.name AS food_category,
	cp.value AS price,
	cpib.name AS industry_name,
	cp2.value AS avg_wages,
	cp2.payroll_year,
	cp.date_from,
	to_char(cp.date_from, 'DD. Month YYYY'),
	to_char(cp.date_from, 'DD. MM. YYYY')
FROM czechia_price cp
JOIN czechia_payroll cp2 
	ON cp2.payroll_year = date_part('year', cp.date_from)
	AND cp2.value_type_code = 5958
	AND cp.region_code IS NULL
JOIN czechia_price_category cpc 
	ON cpc.code = cp.category_code
JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp2.industry_branch_code;

-- https://www.postgresql.org/docs/18/functions-formatting.html



/* 
 * Cvičení: Kartézský součin a CROSS JOIN
 */


/*
 * Úkol 1: Spojte tabulky czechia_price a czechia_price_category pomocí kartézského součinu.
 */


SELECT *
FROM czechia_price, czechia_price_category;

SELECT *
FROM czechia_price cp, czechia_price_category cpc
WHERE cp.category_code = cpc.code;


-- Úkol 2: Převeďte předchozí příklad do syntaxe s CROSS JOIN.

SELECT *
FROM czechia_price cp
CROSS JOIN czechia_price_category cpc 
WHERE cp.category_code = cpc.code;


/*
 * Úkol 3: Vytvořte všechny kombinace krajů kromě těch případů, kdy by se v obou sloupcích kraje shodovaly.
 */

SELECT *
FROM czechia_region cr 
CROSS JOIN czechia_region cr2
WHERE cr.code != cr2.code;

-- pokracovani 19:58


-- Cvičení: Množinové operace


/*
Úkol 1: Přepište následující dotaz na variantu spojení 
dvou separátních dotazů se selekcí pro každý kraj zvlášť.
*/


SELECT category_code, value
FROM czechia_price
WHERE region_code IN ('CZ064', 'CZ010');


SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
UNION ALL
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ010';


-- Úkol 2: Upravte předchozí dotaz tak, aby byly odstraněny duplicitní záznamy.

SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
UNION
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ010';


-- Úkol 3: Sjednoťe kraje a okresy do jedné množiny. Tu následně seřaďte dle kódu vzestupně.

SELECT *
FROM (
	SELECT code, name, 'region' AS country_part
	FROM czechia_region
	UNION
	SELECT code, name, 'district' AS country_part
	FROM czechia_district
) country_parts
ORDER BY code ASC;

-- Úkol 4: Vytvořte průnik cen z krajů Hl. město Praha a Jihomoravský kraj.

SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
INTERSECT
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ010';


/*
Úkol 5: Vypište kód a název odvětví, ID záznamu a hodnotu záznamu průměrných mezd a
počtu zaměstnanců. Vyberte pouze takové záznamy, které se shodují v uvedené hodnotě 
a spadají do odvětví s označením A nebo B.
*/

SELECT 
	cpib.*,
	cp.id,
	cp.value 
FROM czechia_payroll cp 
JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code 
WHERE cp.value IN (
	SELECT value
	FROM czechia_payroll cp 
	WHERE industry_branch_code = 'A'
	INTERSECT 
	SELECT value
	FROM czechia_payroll cp 
	WHERE industry_branch_code = 'B'
);


/*
 * Úkol 6: Vyberte z tabulky czechia_price takové záznamy, 
 * které jsou v Jihomoravském kraji jiné na sloupcích category_code a value než v Praze.
 */


SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ064'
EXCEPT
SELECT category_code, value
FROM czechia_price
WHERE region_code = 'CZ010';

-- https://www.markdownguide.org/basic-syntax/


