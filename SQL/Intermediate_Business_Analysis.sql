
-- INTERMEDIATE BUSINESS ANALYSIS -- 

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 19
   Average Annual Content Production by Marvel Universe
   ========================================================= */

-- 19. Which Marvel universes have the highest average number of titles released per year? -- 

SELECT
    universe AS Marvel_Universe,
    COUNT(*) AS Total_Titles,
    COUNT(DISTINCT year) AS Active_Years,

    CAST(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT year)
        AS DECIMAL(10,2)
    ) AS Avg_Titles_Per_Year

FROM dbo.marvel_master_clean

GROUP BY
    universe

ORDER BY
    Avg_Titles_Per_Year DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 20
   Marvel Universe Content Growth Over Time
   ========================================================= */

-- 20. Which Marvel universe has experienced the greatest growth in content production over time? -- 

WITH Yearly_Universe_Count AS
(
    SELECT
        universe AS Marvel_Universe,
        Year AS Release_Year,
        COUNT(*) AS Title_Count
    FROM marvel_master_clean
    GROUP BY universe, year
),
Universe_Growth AS
(
    SELECT
        Marvel_Universe,
        MIN(Release_Year) AS First_Release_Year,
        MAX(Release_Year) AS Latest_Release_Year,
        MAX(Title_Count) AS Highest_Annual_Output,
        MIN(Title_Count) AS Lowest_Annual_Output
    FROM Yearly_Universe_Count
    GROUP BY Marvel_Universe
)
SELECT
    Marvel_Universe,
    First_Release_Year,
    Latest_Release_Year,
    Highest_Annual_Output,
    Lowest_Annual_Output,
    Highest_Annual_Output - Lowest_Annual_Output AS Annual_Output_Range
FROM Universe_Growth
ORDER BY Annual_Output_Range DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 21
   MCU vs Non-MCU Content Production Across Periods
   ========================================================= */

-- 21. How does Marvel content production differ between MCU and Non-MCU titles across different periods? -- 

SELECT
    year AS Release_Year,

    SUM(
        CASE
            WHEN is_mcu_canon = 1 THEN 1
            ELSE 0
        END
       ) AS MCU_Titles,

    SUM(
        CASE
            WHEN is_mcu_canon = 0 THEN 1
            ELSE 0
        END
        ) AS Non_MCU_Titles,

        COUNT(*) AS Total_Titles
        
    FROM marvel_master_clean

GROUP BY year

ORDER BY Release_Year;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 22
   Marvel Content Production by Decade
   ========================================================= */

-- 22. Which decades experienced the strongest growth in Marvel content production? -- 

-- Exploring the Release_Decade and Title_Count data -- 

SELECT
    year AS Release_Year,
    CONCAT((year / 10) * 10, ' s') AS Release_Decade,
    COUNT(*) AS Title_Count
FROM marvel_master_clean
GROUP BY
    year,
    (year / 10) * 10
ORDER BY
    year;

-- Analyzing Decade Content and Decade Growth -- 

WITH Decade_Content AS
(
    SELECT
        (year / 10) * 10 AS Release_Decade,
        COUNT(*) AS Total_Titles
    FROM marvel_master_clean
    GROUP BY 
        (year / 10) * 10
),
Decade_Growth AS
(
    SELECT
        Release_Decade,
        Total_Titles,

        LAG(Total_Titles) OVER (
            ORDER BY Release_Decade
        ) AS Previous_Decade_Titles
    FROM Decade_Content
)
SELECT
    Release_Decade,
    Total_Titles,
    Previous_Decade_Titles,

    Total_Titles - Previous_Decade_Titles AS Title_Growth,

    CAST(
        (Total_Titles - Previous_Decade_Titles) * 100.0
        /NULLIF(Previous_Decade_Titles,0)
        AS DECIMAL(5,2)
        ) AS Growth_Percentage

FROM Decade_Growth
WHERE Previous_Decade_Titles IS NOT NULL
ORDER BY Growth_Percentage DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 23
   Movie-to-TV-Series Ratio by Marvel Universe
   ========================================================= */

-- 23. How does the movie-to-TV-series ratio differ across Marvel universes? -- 

SELECT
    universe AS Marvel_Universe,

    SUM(
        CASE
            WHEN type = 'movie' THEN 1
            ELSE 0
        END
        ) AS movie_count,
    
    SUM(
        CASE
            WHEN type = 'series' THEN 1
            ELSE 0
        END
        ) AS tv_series_count,
    
    CAST(
        SUM(
            CASE
                WHEN type = 'movie' THEN 1
                ELSE 0
            END
        ) * 1.0
        /
        NULLIF(
            SUM(
                CASE
                    WHEN type = 'series' THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Movie_to_TV_Ratio
    
FROM marvel_master_clean

GROUP BY universe
ORDER BY Movie_to_TV_Ratio DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 24
   Average Rating: Movies vs TV Series
   ========================================================= */

-- 24. Do Marvel movies or TV series have higher average ratings? -- 

SELECT
    m.type AS Content_Type,
    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.type, r.source

ORDER BY r.source, Average_Rating DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 25
   Average Rating: Animated vs Non-Animated
   ========================================================= */

-- 25. Do animated or non-animated Marvel titles have higher average ratings? -- 

SELECT 
    CASE
        WHEN m.is_animated = 1 THEN 'Animated'
        ELSE 'Non-Animated'
    END AS Content_Type,

    r.source AS Rating_Source,
    
    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE 
    r.score IS NOT NULL

GROUP BY m.is_animated, r.source

ORDER BY r.source, Average_Rating DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 26
   Average Rating by Marvel Universe
   ========================================================= */

-- 26. Which Marvel universe has the highest average rating based on available ratings? -- 

SELECT
    m.universe AS Marvel_Universe,
    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.universe, r.source

ORDER BY r.source, Average_Rating DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 27
   Lowest Average Rating by Marvel Universe
   ========================================================= */

-- 27. Which Marvel universe has the lowest average rating based on available ratings? -- 

SELECT
    m.universe AS Marvel_Universe,
    r.source AS Rating_Source,

    COUNT(*) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.universe, r.source
ORDER BY r.source, Average_Rating ASC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 28
   Rating Coverage: Movies vs TV Series
   ========================================================= */

-- 28. How does rating coverage differ between Movies and TV Series? -- 

SELECT
    m.type AS Content_Type,
    r.source AS Rating_Source,

    COUNT(*) AS Total_Titles,

    COUNT(r.score) AS Rated_Titles,

    COUNT(*) - COUNT(r.score) AS Missing_Ratings,

    CAST(
        COUNT(r.score) * 100.0 / NULLIF(COUNT(*),0)
        AS DECIMAL(10,2)
        ) AS Rating_Coverage_Percentage

FROM marvel_master_clean AS m

LEFT JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    and m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.type, r.source

ORDER BY r.source, Rating_Coverage_Percentage DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 29
   Rating Coverage: MCU vs Non-MCU
   ========================================================= */

-- 29. How does rating coverage differ between MCU and Non-MCU content? -- 

SELECT
    CASE
        WHEN m.is_mcu_canon = 1 THEN 'MCU'
        ELSE 'Non-MCU'
    END AS Content_Category,

r.source AS Rating_Source,

COUNT(*) AS Total_Titles,
COUNT(r.score) AS Rated_Titles,
COUNT(*) - COUNT(r.score) AS Missing_Ratings,

CAST(
    COUNT(r.score) * 100.0 / NULLIF (COUNT(*),0)
    AS DECIMAL(10,2)
    ) AS Rating_Coverage_Percentage

FROM marvel_master_clean AS m

LEFT JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.is_mcu_canon, r.source

ORDER BY r.source, Rating_Coverage_Percentage;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 30
   Content Volume vs Average Rating by Marvel Universe
   ========================================================= */

-- 30. Which Marvel universe has the strongest combination of content volume and average rating? -- 

SELECT 
    m.universe AS Marvel_Universe,
    r.source AS Rating_Source,

    COUNT(DISTINCT m.title + '|' + CAST(m.year AS VARCHAR(4)))
    AS Total_Titles, 

   COUNT(r.score) AS Rated_Titles,

   CAST(
    AVG(r.score) AS DECIMAL(10,2)
    ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.universe, r.source

ORDER BY r.source, Average_Rating DESC, Total_Titles DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 31
   High Content Volume but Relatively Low Average Rating
   ========================================================= */
   
-- 31. Which Marvel universes have a high content volume but relatively low average rating? -- 

WITH Universe_Volume AS
(
    SELECT
        universe AS Marvel_Universe,
        COUNT(*) AS Total_Titles
    FROM marvel_master_clean
    GROUP BY universe
),

Universe_Ratings AS
(
    SELECT
        m.universe AS Marvel_Universe,
        r.source AS Rating_Source,

        COUNT(r.score) AS Rated_Titles,

        CAST(
            AVG(r.score) AS DECIMAL(10,2)
            ) AS Average_Rating

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE 
        r.score IS NOT NULL

    GROUP BY m.universe, r.source
)

SELECT
    v.Marvel_Universe,
    r.Rating_Source,
    v.Total_Titles,
    r.Rated_Titles,
    r.Average_Rating,

    DENSE_RANK() OVER (
        PARTITION BY r.Rating_Source
        ORDER BY v.Total_Titles DESC
    ) AS Volume_Rank,

     DENSE_RANK() OVER (
        PARTITION BY r.Rating_Source
        ORDER BY r.Average_Rating ASC
    ) AS Rating_Rank

FROM Universe_Volume AS v

INNER JOIN Universe_Ratings AS r
    ON v.Marvel_Universe = r.Marvel_Universe

ORDER BY
    r.Rating_Source,
    Volume_Rank,
    Rating_Rank;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 32
   Low Content Volume but Relatively High Average Rating
   ========================================================= */

-- 32. Which Marvel universes have a low content volume but relatively high average rating? --

WITH Universe_Volume AS
(
    SELECT
        universe AS Marvel_Universe,
        COUNT(*) AS Total_Titles
    FROM marvel_master_clean
    GROUP BY universe
),

Universe_Ratings AS
(
    SELECT
        m.universe AS Marvel_Universe,
        r.source AS Rating_Source,

        COUNT(r.score) AS Rated_Titles,

        CAST(
            AVG(r.score) AS DECIMAL(10,2)
           ) AS Average_Rating
           

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

    GROUP BY m.universe, r.source

)

SELECT
    v.Marvel_Universe,
    r.Rating_Source,
    v.Total_Titles,
    r.Average_Rating,

    DENSE_RANK() OVER (
        PARTITION BY r.Rating_Source
        ORDER BY v.Total_Titles ASC
    ) AS Volume_Rank,

    DENSE_RANK() OVER (
        PARTITION BY r.Rating_Source
        ORDER BY r.Average_Rating DESC
    ) AS Rating_Rank

FROM Universe_Volume AS v

INNER JOIN Universe_Ratings AS r
    ON v.Marvel_Universe = r.Marvel_Universe

ORDER BY
    r.Rating_Source,
    Volume_Rank,
    Rating_Rank;
  
/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 33
   Average Rating: MCU Canon vs Non-MCU Content
   ========================================================= */

-- 33. How does MCU Canon content compare with Non-MCU content in terms of average ratings? -- 

SELECT
    CASE
        WHEN m.is_mcu_canon = 1 THEN 'MCU'
        ELSE 'Non-MCU'
    END AS Content_Category,

    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.is_mcu_canon, r.source

ORDER BY r.source, Average_Rating DESC;


/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 34
   Animated vs Non-Animated: Content Volume & Ratings
   ========================================================= */

-- 34. How does animated Marvel content compare with non-animated content in terms of content volume and ratings? -- 

WITH
    Content_Volume AS
(
    SELECT
        CASE 
            WHEN is_animated = 1 THEN 'Animated'
            ELSE 'Non-Animated'
        END AS Content_Category,

        COUNT(*) AS Total_Titles
    FROM marvel_master_clean
    GROUP BY is_animated
),

Content_Ratings AS
(
    SELECT
        CASE
            WHEN m.is_animated = 1 THEN 'Animated'
            ELSE 'Non-Animated'
        END AS Content_Category,

    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating
    
    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

    GROUP BY m.is_animated, r.source

)

SELECT
    v.Content_Category,
    r.Rating_Source,
    v.Total_Titles,
    r.Rated_Titles,

    CAST(
        r.Rated_Titles * 100.0 / NULLIF(v.Total_Titles,0) 
        AS DECIMAL (10,2)
        ) AS Rating_Coverage_Percentage,

    r.Average_Rating

FROM Content_Volume AS v

INNER JOIN Content_Ratings AS r
    ON v.Content_Category = r.Content_Category

ORDER BY r.Rating_Source, Average_Rating DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 35
   Average Marvel Rating Trend by Release Year
   ========================================================= */

-- 35. How has the average rating of Marvel content changed over the years? -- 

SELECT
    m.year AS Release_Year,
    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE
    r.score IS NOT NULL

GROUP BY m.year, r.source

ORDER BY m.year, r.source;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 36
   Highest-Rated Marvel Content by Release Year
   ========================================================= */

-- 36. Which release years produced the highest-rated Marvel content? -- 

SELECT
    m.year AS Release_Year,
    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.year, r.source

ORDER BY r.source, Average_Rating DESC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 37
   Lowest-Rated Marvel Content by Release Year
   ========================================================= */

-- Which release years produced the lowest-rated Marvel content? -- 

SELECT
    m.year AS Release_Year,
    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
        ) AS Average_Rating

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

GROUP BY m.year, r.source

ORDER BY r.source, Average_Rating ASC;

/* =========================================================
   INTERMEDIATE BUSINESS ANALYSIS — QUESTION 38
   Older vs Newer Marvel Content: Rating Performance
   ========================================================= */

-- 38. Does rating performance differ between older and newer Marvel content? --

WITH Valid_Years AS                       --- As year is nvarchar(max) in our data so converting it to Int for calculation purpose -- 
(
    SELECT
        TRY_CAST(m.year AS INT) AS Release_Year
    FROM dbo.marvel_master_clean AS m
    WHERE
        TRY_CAST(m.year AS INT) IS NOT NULL
),

Median_Year AS
(
    SELECT
        AVG(Release_Year * 1.0) AS Median_Release_Year
    FROM
    (
        SELECT
            Release_Year,
            ROW_NUMBER() OVER (ORDER BY Release_Year) AS Row_Num,
            COUNT(*) OVER () AS Total_Rows
        FROM Valid_Years
    ) AS y
    WHERE
        Row_Num IN (
            (Total_Rows + 1) / 2,
            (Total_Rows + 2) / 2
        )
)

SELECT
    CASE
        WHEN TRY_CAST(m.year AS INT) <= Median_Release_Year
            THEN 'Older Content'
        ELSE 'Newer Content'
    END AS Content_Period,

    r.source AS Rating_Source,

    COUNT(r.score) AS Rated_Titles,

    CAST(
        AVG(r.score) AS DECIMAL(10,2)
    ) AS Average_Rating

FROM dbo.marvel_master_clean AS m

CROSS JOIN Median_Year AS my

INNER JOIN dbo.marvel_ratings_clean AS r
    ON m.title = r.title
   AND m.year = r.year

WHERE
    TRY_CAST(m.year AS INT) IS NOT NULL
    AND r.score IS NOT NULL

GROUP BY
    CASE
        WHEN TRY_CAST(m.year AS INT) <= Median_Release_Year
            THEN 'Older Content'
        ELSE 'Newer Content'
    END,
    r.source

ORDER BY
    r.source,
    Average_Rating DESC;
        
