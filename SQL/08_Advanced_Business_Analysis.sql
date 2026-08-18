USE Marvel_SQL_Analysis;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 39
   Highest Overall Average-Rated Marvel Titles
   ========================================================= */

-- 39. Which Marvel titles have the highest overall average rating across available rating sources? -- 

WITH Normalized_Ratings AS
(
    SELECT
        m.title,

        r.source,

        CASE
            WHEN r.source IN ('IMDb','TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL
        END AS Normalized_Score

    FROM dbo.marvel_master_clean AS m

    INNER JOIN dbo.marvel_ratings_clean AS r
        ON m.title = r.title
       AND m.year = r.year

    WHERE
        r.score IS NOT NULL
)

SELECT
    title,

    COUNT(Normalized_Score) AS Rating_Count,

    CAST(
        AVG(Normalized_Score) AS DECIMAL(10,2)
    ) AS Average_Rating

FROM Normalized_Ratings

WHERE
    Normalized_Score IS NOT NULL

GROUP BY
    title

HAVING
    COUNT(Normalized_Score) >= 2

ORDER BY
    Average_Rating DESC,
    Rating_Count DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 40
   Largest Rating Differences Across Sources
   ========================================================= */

-- 40. Which Marvel titles have the largest difference between their highest and lowest ratings across sources? -- 

WITH Normalized_Ratings AS
(
    SELECT
        m.title,

        r.source,

        CASE
            WHEN r.source IN ('IMDb', 'TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL
        END AS Normalized_Score

    FROM dbo.marvel_master_clean AS m

    INNER JOIN dbo.marvel_ratings_clean AS r
        ON m.title = r.title
       AND m.year = r.year

    WHERE
        r.score IS NOT NULL
)

SELECT
    title,

    COUNT(Normalized_Score) AS Rating_Count,

    CAST(
        MIN(Normalized_Score) AS DECIMAL(10,2)
    ) AS Lowest_Rating,

    CAST(
        MAX(Normalized_Score) AS DECIMAL(10,2)
    ) AS Highest_Rating,

    CAST(
        MAX(Normalized_Score) - MIN(Normalized_Score)
        AS DECIMAL(10,2)
    ) AS Rating_Difference

FROM Normalized_Ratings

WHERE
    Normalized_Score IS NOT NULL

GROUP BY
    title

HAVING
    COUNT(Normalized_Score) >= 2

ORDER BY
    Rating_Difference DESC,
    Rating_Count DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 41
   Marvel Titles Performing Above Overall Average Rating
   ========================================================= */

-- Q41. Which Marvel titles perform above the overall Marvel average rating across multiple rating sources? -- 

WITH Normalized_Ratings AS
(
    SELECT
        m.title,

        r.source,

        CASE
            WHEN r.source IN ('IMDb, TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score
    
    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL
),

Overall_Average AS
(
    SELECT
        AVG(Normalized_Score) AS Overall_Average_Rating
    FROM Normalized_Ratings
    WHERE Normalized_Score IS NOT NULL
),

Title_Average AS
(
      SELECT
        title,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE
        Normalized_Score IS NOT NULL

    GROUP BY
        title

    HAVING
        COUNT(Normalized_Score) >= 2
)

SELECT
    t.title,

    t.rating_count,

    CAST(
        t.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating,

    CAST(
        o.Overall_Average_Rating AS DECIMAL(10,2)
        ) AS Overall_Average_Rating,

    CAST(
        t.Average_Rating - o.Overall_Average_Rating
        AS DECIMAL(10,2)
        ) AS Difference_from_Overall_Average

FROM Title_Average AS t

CROSS JOIN Overall_Average AS o

WHERE 
    t.Average_Rating > o.Overall_Average_Rating

ORDER BY 
    Difference_from_Overall_Average DESC,
    Average_Rating DESC;


/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 42
   Highest Average-Rated Marvel Universes
   ========================================================= */

-- 42. Q42. Which Marvel universes have the highest average ratings across available rating sources? -- 

WITH Normalized_Ratings AS
(
    SELECT
        m.universe,

        r. source,

       CASE
    WHEN r.source IN ('IMDb', 'TMDB')
        THEN r.score

    WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
        THEN r.score / 10.0

    ELSE NULL

END AS Normalized_Score

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

),

Universe_Ratings AS
(
    SELECT
        universe,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY universe
)

SELECT
    universe,

    Rating_Count,

    CAST(
        Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Universe_Ratings

WHERE Rating_Count >= 1

ORDER BY 
    Average_Rating DESC,
    Rating_Count DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 43
   Strongest Combination of Content Volume and Average Rating
   ========================================================= */

-- 43. Which Marvel universes have the strongest combination of content volume and average rating? -- 

WITH Normalized_Ratings AS
(  
    SELECT
        m.universe,
        r.source,

        CASE
            WHEN r.source IN ('IMDb','TMDB')
                THEN r.score
            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL
        END AS Normalized_Score

    FROM marvel_master_clean AS m
    
    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL
),

Universe_Ratings AS

(
    SELECT
        universe,

        COUNT(Normalized_Score) AS Rating_Count,
        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY universe

),

Universe_Volume AS

(
    SELECT
        universe,
        
        COUNT(*) AS Content_Volume

    FROM marvel_master_clean 

    GROUP BY universe
)

SELECT 
    v.universe, 
    v.Content_Volume,
    r.Rating_Count,

    CAST(
        r.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Universe_Volume AS v

INNER JOIN Universe_Ratings AS r
    ON v.universe = r.universe

WHERE 
    r.Rating_Count >= 1

ORDER BY 
    Average_Rating DESC,
    Content_Volume DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 44
   High Content Volume but Below-Average Ratings
   ========================================================= */

-- 44. Which Marvel universes have high content volume but below-average ratings? --

WITH Normalized_Ratings AS

(
    SELECT
        m.universe,

        r.source,

        CASE
            WHEN r.source IN ('IMDb','TMDB')
                THEN r.score
            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0
            
            ELSE NULL

        END AS Normalized_Score
    
    FROM marvel_master_clean AS m
    
    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

),

Universe_Ratings AS

(
    SELECT
        universe,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY universe

),

Universe_Volume AS

(
    SELECT
        universe,

        COUNT(*) AS Content_Volume

    FROM marvel_master_clean

    GROUP BY universe

),

Overall_Average AS

(
    SELECT
        AVG(Normalized_Score) AS Overall_Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

)

SELECT

    v.universe,
    v.Content_Volume,
    r.Rating_Count,

    CAST(
        r.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating,

    CAST(
        o.Overall_Average_Rating AS DECIMAL(10,2)
        ) AS Overall_Average_Rating

FROM Universe_Volume AS v

INNER JOIN Universe_Ratings AS r
    ON v.universe = r.universe

CROSS JOIN Overall_Average AS o

WHERE
    r.Average_Rating < O.Overall_Average_Rating

ORDER BY
    v.Content_Volume DESC,
    r.Average_Rating ASC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 45
   Movie vs TV Series: Content Volume and Rating Performance
   ========================================================= */

-- 45. Which content type—Movie or TV Series—performs better when considering both content volume and average rating? --

WITH Normalized_Ratings AS

(
    SELECT

        m.type,
        

        CASE
            WHEN r.source IN ('IMDb', 'TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score

FROM marvel_master_clean AS m

INNER JOIN marvel_ratings_clean AS r
    ON m.title = r.title
    AND m.year = r.year

WHERE r.score IS NOT NULL

),

Content_Ratings AS

(   
    SELECT
        type,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE
        Normalized_Score IS NOT NULL

    GROUP BY 
        type

),

Content_Volume AS

(
    SELECT
        type,

        COUNT(*) AS Content_Volume

    FROM marvel_master_clean

    GROUP BY type

)

SELECT
    v.type,

    v.Content_Volume,

    r.Rating_Count,

    CAST(
        r.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Content_Volume AS v

INNER JOIN Content_Ratings AS r
    ON v.type = r.type

ORDER BY 
    Average_Rating DESC,
    Content_Volume DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 46
   Animated vs Non-Animated: Content Volume and Rating Performance
   ========================================================= */

-- 46. Which animation category—Animated or Non-Animated—performs better when considering both content volume and average rating? -- 

WITH Normalized_Ratings AS

(
    SELECT
        m.is_animated,

        CASE
            WHEN r.source IN ('IMDb','TMBd')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

),

Animation_Ratings AS

(
    SELECT
        is_animated,

        COUNT(Normalized_Score) AS Rating_Count,
        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY
        is_animated

),

Animation_Volume AS

(
    SELECT
        is_animated,

        COUNT(*) AS Content_Volume

    FROM marvel_master_clean

    GROUP BY
        is_animated

)

SELECT
    CASE
        WHEN v.is_animated = 1
            THEN 'Animated'

        ELSE 'Non-Animated'

    END AS Animation_Category,

    v.Content_Volume,

    r.Rating_Count,

    CAST(
        r.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Animation_Volume AS v

INNER JOIN Animation_Ratings AS r
    ON v.is_animated = r.is_animated

ORDER BY
    Average_Rating DESC,
    Content_Volume;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 47
   Release Periods with Strongest Content Volume and Ratings
   ========================================================= */

-- 47. Which release periods have the strongest combination of content volume and average rating? --

WITH Normalized_Ratings AS

(
    SELECT

        CASE
        WHEN TRY_CAST(m.year AS INT) BETWEEN 1930 AND 1999
            THEN 'Before 2000'

        WHEN TRY_CAST(m.year AS INT) BETWEEN 2000 AND 2009
            THEN '2000-2009'

        WHEN TRY_CAST(m.year AS INT) BETWEEN 2010 AND 2019
            THEN '2010-2019'
            
        WHEN TRY_CAST(m.year AS INT) >= 2020
            THEN '2020 Onwards'

        ELSE NULL

        END AS Release_Period,

        CASE
            WHEN r.source IN ('IMDb', 'TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL
    AND TRY_CAST(m.year AS INT) IS NOT NULL

),

Period_Ratings AS

(

    SELECT
        Release_Period,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY
        Release_Period

),

Period_Volume AS

(
    SELECT
        CASE
            WHEN TRY_CAST(year AS INT) BETWEEN 1930 AND 1999
                THEN 'Before 2000'

            WHEN TRY_CAST(year AS INT) BETWEEN 2000 AND 2009
                THEN '2000-2009'

            WHEN TRY_CAST(year AS INT) BETWEEN 2010 AND 2019
                THEN '2010-2019'

            WHEN TRY_CAST(year AS INT) >= 2020
                THEN '2020 Onwards'

            ELSE NULL

        END AS Release_Period,

        COUNT(*) AS Content_Volume

    FROM marvel_master_clean

    WHERE
        TRY_CAST(year AS INT) IS NOT NULL

    GROUP BY
        CASE
            WHEN TRY_CAST(year AS INT) BETWEEN 1930 AND 1999
                THEN 'Before 2000'

            WHEN TRY_CAST(year AS INT) BETWEEN 2000 AND 2009
                THEN '2000-2009'

            WHEN TRY_CAST(year AS INT) BETWEEN 2010 AND 2019
                THEN '2010-2019'

            WHEN TRY_CAST(year AS INT) >= 2020
                THEN '2020 Onwards'

            ELSE NULL

        END
)

SELECT
    v.Release_Period,

    v.Content_Volume,

    r.Rating_Count,

    CAST(
        r.Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Period_Volume AS v

INNER JOIN Period_Ratings AS r
    ON v.Release_Period = r.Release_Period

ORDER BY
    Average_Rating DESC,
    Content_Volume DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 48
   Highest-Rated Universe and Content Type Combination
   ========================================================= */

-- 48. Which Marvel universe and content type combination has the highest average rating? -- 

WITH Normalized_Ratings AS

(
    SELECT
        m.universe,

        m.type,

        CASE
            WHEN r.source IN ('IMDb', 'TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomatoes', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

),

Combination_Ratings AS

(
    SELECT
        universe,
        type,

        COUNT(Normalized_Score) AS Rating_Count,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings

    WHERE Normalized_Score IS NOT NULL

    GROUP BY 
        universe,
        type
)

SELECT
    universe,

    type,

    Rating_Count,

    CAST(
        Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Combination_Ratings

WHERE 
    Rating_Count >= 1

ORDER BY 
    Average_Rating DESC,
    Rating_Count DESC;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 49
   Actors with the Highest Number of Marvel Titles
   ========================================================= */

-- 49. Which actors have appeared in the highest number of Marvel titles? -- 

SELECT
   actor_name,

    COUNT(DISTINCT title) AS Marvel_Titles

FROM marvel_cast_clean

GROUP BY 
    actor_name

HAVING
    COUNT(DISTINCT title) >=2

ORDER BY
    Marvel_Titles DESC,
    actor_name;


/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 50
   Actors with the Widest Presence Across Marvel Universes
   ========================================================= */

-- 50. Which actors have appeared across the highest number of Marvel universes? --

SELECT
    c.actor_name,
    
    COUNT(DISTINCT m.universe) AS Marvel_Universe,

    COUNT(DISTINCT c.title) AS Marvel_Titles


FROM marvel_cast_clean AS c

INNER JOIN marvel_master_clean AS m
    ON c.title = m.title
    AND c.year = m.year

GROUP BY c.actor_name

HAVING 
    COUNT(DISTINCT m.universe) >= 2

ORDER BY 
    Marvel_Universe DESC,
    Marvel_Titles DESC,
    c.actor_name;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 51
   Actors Associated with the Highest-Rated Marvel Titles
   ========================================================= */

-- 51. Which actors are associated with the highest-rated Marvel titles? -- 

WITH Normalized_Ratings AS

(
    SELECT
        m.title,
        m.year,

        CASE
            WHEN r.source IN ('IMDB','TMDB')
                THEN r.score

            WHEN r.source IN ('Rotten Tomates', 'Metacritic')
                THEN r.score / 10.0

            ELSE NULL

        END AS Normalized_Score

    FROM marvel_master_clean AS m

    INNER JOIN marvel_ratings_clean AS r
        ON m.title = r.title
        AND m.year = r.year

    WHERE r.score IS NOT NULL

),

Title_Ratings AS

(

    SELECT
        title,
        year,

        AVG(Normalized_Score) AS Average_Rating

    FROM Normalized_Ratings 

    WHERE 
        Normalized_Score IS NOT NULL

    GROUP BY
        title,
        year

),

Actor_Ratings AS

(
    SELECT
        c.actor_name,

        COUNT(DISTINCT c.title) AS Marvel_Titles,

        AVG(t.Average_Rating) AS Average_Rating

    FROM marvel_cast_clean AS c

    INNER JOIN Title_Ratings AS t
        ON c.title = t.title
        AND c.year = t.year

    GROUP BY
        c.actor_name
)

SELECT
    actor_name,

    Marvel_Titles,

    CAST(
        Average_Rating AS DECIMAL(10,2)
        ) AS Average_Rating

FROM Actor_Ratings

WHERE 
    Marvel_Titles >= 2

ORDER BY 
    Average_Rating DESC,
    Marvel_Titles DESC,
    actor_name;

/* =========================================================
   ADVANCED BUSINESS ANALYSIS — QUESTION 52
   Largest and Most Diverse Cast Presence by Marvel Universe
   ========================================================= */

-- 52.Which Marvel universes have the largest and most diverse cast presence? --

SELECT
    m.universe,
    
    COUNT(DISTINCT c.actor_name) AS Unique_Actors,

    COUNT(DISTINCT c.title) AS Marvel_Titles,

    COUNT(*) AS Cast_Records

FROM marvel_master_clean AS m

INNER JOIN marvel_cast_clean AS c
    ON m.title = c.title
    AND m.year = c.year

GROUP BY 
    m.universe

ORDER BY 
    Unique_Actors DESC,
    Marvel_Titles DESC; 










    
      




        

    
       
    
