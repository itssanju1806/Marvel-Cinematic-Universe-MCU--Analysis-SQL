
/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 1
   Marvel Content: Movies vs TV Series
   ========================================================= */

-- 1. How many Marvel titles are present in the dataset, and how are they distributed between movies and TV series? -- 

USE Marvel_SQL_Analysis;

SELECT
	CASE
		WHEN is_tv_series = 1 THEN 'TV Series'
		WHEN is_tv_series = 0 THEN 'Movie / Other'
	END AS Content_Type,
	COUNT(*) AS	Title_Count,
	CAST(
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
		AS DECIMAL(5,2)
		) AS Percentage_Of_Total
FROM marvel_master_clean
GROUP BY 
	is_tv_series
ORDER BY 
	Title_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 2
   Marvel Content Output by Year
   ========================================================= */

-- 2. How many Marvel titles were released in each year, and which years had the highest content output? -- 

SELECT
    TRY_CONVERT(INT, year) AS Release_Year,
    COUNT(*) AS Title_Count
FROM marvel_master_clean
WHERE TRY_CONVERT(INT, year) IS NOT NULL
GROUP BY
    TRY_CONVERT(INT, year)
ORDER BY
    Release_Year;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 3
   Marvel Content Distribution by Decade
   ========================================================= */

-- 3. How is Marvel content distributed across different decades? --

SELECT
    CONCAT(
        (TRY_CONVERT(INT, year) / 10) * 10,
        's'
    ) AS Decade,
    COUNT(*) AS Title_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage_of_Total
FROM marvel_master_clean
WHERE TRY_CONVERT(INT, year) IS NOT NULL
GROUP BY
    (TRY_CONVERT(INT, year) / 10) * 10
ORDER BY
    (TRY_CONVERT(INT, year) / 10) * 10;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 4
   Marvel Content Distribution by Universe
   ========================================================= */

-- 4. How is Marvel content distributed across the different universes? -- 

SELECT 
    universe AS Marvel_Universe,
    COUNT(*) AS Title_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
        ) AS Percentage_Of_Total
FROM marvel_master_clean
GROUP BY universe
ORDER BY Title_Count;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 5
   MCU Canon vs Non-MCU Canon
   ========================================================= */

-- 5. How many Marvel titles are MCU canon compared with non-MCU canon? --

SELECT
    CASE
        WHEN is_mcu_canon = 1 THEN 'MCU Canon'
        WHEN is_mcu_canon = 0 THEN 'Non-MCU Canon'
    END AS Canon_Status,
    COUNT(*) AS Title_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
        ) AS Percentage_Of_Total
FROM marvel_master_clean
GROUP BY is_mcu_canon
ORDER BY Title_Count;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 6
   Live-Action vs Animated Content
   ========================================================= */

-- 6. How is Marvel content distributed between live-action and animated titles? -- 

SELECT
    CASE 
       WHEN is_animated = 1 THEN 'Animated'
       WHEN is_animated = 0 THEN 'Live Action'
    END AS Content_Style,
    COUNT(*) AS Title_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
        ) AS Percentage_Of_Total
FROM marvel_master_clean
GROUP BY is_animated
ORDER BY Title_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 7
   Movies vs TV Series by Marvel Universe
   ========================================================= */

-- 7. How many movies and TV series exist within each Marvel universe? -- 

SELECT
    universe AS Marvel_Universe,

    SUM(
        CASE
            WHEN is_tv_series = 0 THEN 1
            ELSE 0
        END
    ) AS Movie_Count,

    SUM(
        CASE
            WHEN is_tv_series = 1 THEN 1
            ELSE 0
        END
    ) AS TV_Series_Count,
    
    COUNT(*) AS Total_Titles

FROM marvel_master_clean
GROUP BY universe
ORDER BY Total_Titles;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 8
   Marvel Universes by Number of Movies
   ========================================================= */

-- 8. Which Marvel universes have produced the highest number of movies? -- 

SELECT
    universe AS Marvel_Universe,
    COUNT(*) AS Movie_Count
FROM marvel_master_clean
WHERE is_tv_series = 0
GROUP BY universe
ORDER BY Movie_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 9
   Marvel Universes by Number of TV Series
   ========================================================= */

-- 9. Which Marvel universes have produced the highest number of TV series? --

SELECT
    universe AS Marvel_Universe,
    COUNT(*) AS TV_Series_Count
FROM marvel_master_clean
WHERE is_tv_series = 1
GROUP BY universe
ORDER BY TV_Series_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 10
   Movies vs TV Series Production Trend Over Time
   ========================================================= */

-- 10. How has the balance between movies and TV series changed over time? -- 

SELECT
    TRY CONVERT(INT, year) AS Release_Year,

    SUM(
        CASE
            WHEN is_tv_series = 0 THEN 1
            ELSE 0
        END
        ) AS Movie_Count,

    SUM(
        CASE
            WHEN is_tv_series = 1 THEN 1
            ELSE 0
        END
        ) AS TV_Series_Count,
    COUNT(*) AS Total_Titles
FROM marvel_master_clean
WHERE TRY CONVERT(INT, year) IS NOT NULL
GROUP BY TRY CONVERT(INT, year)
ORDER BY Release_Year;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 11
   Rating Coverage by Source
   ========================================================= */

-- 11. How many ratings are available from each rating source? -- 

SELECT
    source AS Rating_source,
    COUNT(*) AS Rating_Records,
    COUNT(score) AS Available_Scores,
    COUNT(*) - COUNT(score) AS Missing_Scores
FROM marvel_ratings_clean
GROUP BY source
ORDER BY Rating_Records;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 12
   Average Rating by Rating Source
   ========================================================= */

-- 12. What is the average rating for Marvel content across each rating source? -- 

SELECT
    source AS Rating_source,
    COUNT(score) AS Rated_Titles,
    CAST(
        AVG(TRY_CONVERT(DECIMAL(10,2),score))
    AS DECIMAL(5,2)) AS Average_Rating
FROM marvel_ratings_clean
GROUP BY source
ORDER BY Average_Rating;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 13
   Highest-Rated Marvel Titles
   ========================================================= */

-- 13. Which Marvel titles have the highest ratings according to each rating source? -- 

SELECT
    m.title,
    m.year,
    r.source AS Rating_Source,
    r.score AS Rating_Score
FROM marvel_master_clean as m
INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year
WHERE r.score IS NOT NULL
ORDER BY r.source, r.score DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 14
   Lowest-Rated Marvel Titles
   ========================================================= */

-- 14. Which Marvel titles have the lowest ratings according to each rating source? -- 

SELECT
    m.title,
    m.year,
    r.source AS Rating_Source,
    r.score AS Rating_Score
FROM marvel_master_clean as m
INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year
WHERE r.score IS NOT NULL
ORDER BY r.source, r.score ASC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 15
   Rating Coverage of Marvel Catalog by Source
   ========================================================= */

-- 15. How many Marvel titles are rated by each rating source, 
-- and what percentage of the total Marvel catalog does each source cover? -- 

SELECT
    r.source as Rating_Source,
    COUNT(r.score) AS Rated_Titles,
    CAST(
        COUNT(r.score)* 100.0/(SELECT COUNT(*) FROM marvel_master_clean)
        AS DECIMAL(5,2)
        ) AS Catalog_Coverage_Percentage
FROM marvel_ratings_clean AS r
GROUP BY r.source
ORDER BY Catalog_Coverage_Percentage DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 16
   Marvel Content Distribution by Universe
   ========================================================= */

-- 16. How is the Marvel content catalog distributed across different universes? -- 

SELECT
    universe AS Marvel_Universe,
    COUNT(*) AS Title_Count,
    CAST(
        COUNT(*) * 100.0 /(SELECT COUNT(*) FROM marvel_master_clean)
        AS DECIMAL(5,2)
        ) AS Percentage_of_Catalog
FROM marvel_master_clean
GROUP BY universe
ORDER BY Title_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 17
   MCU vs Non-MCU Content Distribution
   ========================================================= */

-- 17. How is Marvel content distributed across MCU and non-MCU universes? -- 

SELECT
    CASE
        WHEN is_mcu_canon = 1 THEN 'MCU'
        ELSE 'Non-MCU'
    END AS Content_Category,

    COUNT(*) AS Total_Count,

    CAST(
         COUNT(*) * 100 /(SELECT COUNT(*) FROM marvel_master_clean)
         AS DECIMAL(5,2)
        ) AS Percentage_of_Catalog
      
FROM marvel_master_clean

GROUP BY is_mcu_canon
ORDER BY Total_Count DESC;

/* =========================================================
   BASIC BUSINESS ANALYSIS — QUESTION 18
   Animated vs Non-Animated Content Distribution
   ========================================================= */

-- 18. How is Marvel content distributed between animated and non-animated titles? -- 

SELECT
    CASE
        WHEN is_animated = 1 THEN 'Animated'
        ELSE 'Non-Animated'
    END AS Content_Type,

    COUNT(*) AS Total_Count,

    CAST(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM marvel_master_clean)
        AS DECIMAL(5,2)
        ) AS Percentage_of_Catalog

FROM marvel_master_clean
GROUP BY is_animated
ORDER BY Total_Count DESC;


