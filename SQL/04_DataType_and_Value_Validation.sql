
-- DATA TYPE & VALUE VALIDATION --

-- Master Table --

-- 1A — Check numeric-looking columns for non-numeric values --

SELECT
    'id' AS Column_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(id)), '') IS NOT NULL
         AND TRY_CONVERT(BIGINT, id) IS NULL
        THEN 1 ELSE 0
    END) AS Invalid_Numeric_Values
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'year',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(year)), '') IS NOT NULL
         AND TRY_CONVERT(INT, year) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'tmdb_id',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(20,2), tmdb_id) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'imdb_rating',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(imdb_rating)), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(5,2), imdb_rating) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'imdb_votes',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(imdb_votes)), '') IS NOT NULL
         AND TRY_CONVERT(BIGINT, imdb_votes) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'rt_score',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(rt_score)), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(5,2), rt_score) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'metacritic_score',
    COUNT(*),
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(metacritic_score)), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(5,2), metacritic_score) IS NULL
        THEN 1 ELSE 0
    END)
FROM dbo.marvel_master_raw;

-- 1B — Investigate the 12 Invalid IMDb Ratings --

SELECT
    imdb_rating,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(imdb_rating)), '') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(5,2), imdb_rating) IS NULL
GROUP BY imdb_rating
ORDER BY Record_Count DESC;

-- 1C — Determine the 12 records -- 

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN imdb_rating IS NULL THEN 1 ELSE 0 END) AS SQL_NULL_Count,
    SUM(CASE 
        WHEN imdb_rating IS NOT NULL
         AND LTRIM(RTRIM(imdb_rating)) = ''
        THEN 1 ELSE 0
    END) AS Blank_Count,
    SUM(CASE 
        WHEN NULLIF(LTRIM(RTRIM(imdb_rating)), '') IS NOT NULL
         AND TRY_CONVERT(DECIMAL(5,2), imdb_rating) IS NULL
        THEN 1 ELSE 0
    END) AS Truly_Invalid_Count
FROM dbo.marvel_master_raw;

-- 1D - Identify those 12 invalid values --

SELECT
    '[' + imdb_rating + ']' AS Raw_IMDb_Rating,
    LEN(imdb_rating) AS Value_Length,
    DATALENGTH(imdb_rating) AS Data_Length,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(imdb_rating)), '') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(5,2), imdb_rating) IS NULL
GROUP BY
    imdb_rating,
    LEN(imdb_rating),
    DATALENGTH(imdb_rating)
ORDER BY Record_Count DESC;

-- 1E — imdb_votes --

SELECT
    '[' + imdb_votes + ']' AS Raw_IMDb_Votes,
    LEN(imdb_votes) AS Value_Length,
    DATALENGTH(imdb_votes) AS Data_Length,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(imdb_votes)), '') IS NOT NULL
  AND TRY_CONVERT(BIGINT, imdb_votes) IS NULL
GROUP BY
    imdb_votes,
    LEN(imdb_votes),
    DATALENGTH(imdb_votes)
ORDER BY Record_Count DESC;

-- Audit conclusion : imdb_votes is not a data-quality problem. It is a formatting/data-type issue caused by the raw CSV import. --

-- 1F — rt_score --

SELECT
    '[' + rt_score + ']' AS Raw_RT_Score,
    LEN(rt_score) AS Value_Length,
    DATALENGTH(rt_score) AS Data_Length,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(rt_score)), '') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(5,2), rt_score) IS NULL
GROUP BY
    rt_score,
    LEN(rt_score),
    DATALENGTH(rt_score)
ORDER BY Record_Count DESC;

-- Audit Conclusion : All 78 values flagged as non-numeric in rt_score are percentage-formatted values
-- No genuinely invalid Rotten Tomatoes scores were identified. -- 

-- 1G — metacritic_score --

SELECT
    '[' + metacritic_score + ']' AS Raw_Metacritic_Score,
    LEN(metacritic_score) AS Value_Length,
    DATALENGTH(metacritic_score) AS Data_Length,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(metacritic_score)), '') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(5,2), metacritic_score) IS NULL
GROUP BY
    metacritic_score,
    LEN(metacritic_score),
    DATALENGTH(metacritic_score)
ORDER BY Record_Count DESC;

-- 1H --

SELECT
    COUNT(*) AS Total_NonBlank,
    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(5,2), metacritic_score) IS NULL
        THEN 1 ELSE 0
    END) AS NonConvertible_Count,
    SUM(CASE
        WHEN NULLIF(LTRIM(RTRIM(metacritic_score)), '') IS NOT NULL
         AND metacritic_score LIKE '%/100'
        THEN 1 ELSE 0
    END) AS Slash100_Count
FROM dbo.marvel_master_raw
WHERE NULLIF(LTRIM(RTRIM(metacritic_score)), '') IS NOT NULL;

-- Audit Conclusion : metacritic_score contains 72 valid scores stored as X/100. 
-- No genuinely malformed values were identified. --

--2 — Rating Range Validation --

-- 2A — IMDb Rating Range --

SELECT
    MIN(TRY_CONVERT(DECIMAL(5,2), imdb_rating)) AS Min_IMDb_Rating,
    MAX(TRY_CONVERT(DECIMAL(5,2), imdb_rating)) AS Max_IMDb_Rating,
    COUNT(
        CASE
            WHEN TRY_CONVERT(DECIMAL(5,2), imdb_rating) IS NOT NULL
            THEN 1
        END
    ) AS Valid_Rating_Count
FROM dbo.marvel_master_raw;

-- 2B — Rotten Tomatoes Score Range --

SELECT
    MIN(
        TRY_CONVERT(
            DECIMAL(5,2),
            REPLACE(rt_score, '%', '')
        )
    ) AS Min_RT_Score,

    MAX(
        TRY_CONVERT(
            DECIMAL(5,2),
            REPLACE(rt_score, '%', '')
        )
    ) AS Max_RT_Score,

    COUNT(
        CASE
            WHEN TRY_CONVERT(
                DECIMAL(5,2),
                REPLACE(rt_score, '%', '')
            ) IS NOT NULL
            THEN 1
        END
    ) AS Valid_RT_Score_Count
FROM dbo.marvel_master_raw;

-- 2C — Metacritic Score Range -- 

SELECT
    MIN(
        TRY_CONVERT(
            DECIMAL(5,2),
            CASE
                WHEN CHARINDEX('/', metacritic_score) > 0
                THEN LEFT(metacritic_score, CHARINDEX('/', metacritic_score) - 1)
                ELSE NULL
            END
        )
    ) AS Min_Metacritic_Score,

    MAX(
        TRY_CONVERT(
            DECIMAL(5,2),
            CASE
                WHEN CHARINDEX('/', metacritic_score) > 0
                THEN LEFT(metacritic_score, CHARINDEX('/', metacritic_score) - 1)
                ELSE NULL
            END
        )
    ) AS Max_Metacritic_Score,

    COUNT(
        CASE
            WHEN TRY_CONVERT(
                DECIMAL(5,2),
                CASE
                    WHEN CHARINDEX('/', metacritic_score) > 0
                    THEN LEFT(metacritic_score, CHARINDEX('/', metacritic_score) - 1)
                    ELSE NULL
                END
            ) IS NOT NULL
            THEN 1
        END
    ) AS Valid_Metacritic_Score_Count

FROM dbo.marvel_master_raw;

-- 3 — Year Validation -- 

-- 3A — Year Range --

SELECT
    MIN(TRY_CONVERT(INT, year)) AS Min_Year,
    MAX(TRY_CONVERT(INT, year)) AS Max_Year,
    COUNT(
        CASE
            WHEN TRY_CONVERT(INT, year) IS NOT NULL
            THEN 1
        END
    ) AS Valid_Year_Count
FROM dbo.marvel_master_raw;

-- 3B — Identify Suspicious Years --

SELECT
    year,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE TRY_CONVERT(INT, year) IS NOT NULL
  AND (
        TRY_CONVERT(INT, year) < 1900
        OR TRY_CONVERT(INT, year) > YEAR(GETDATE())
      )
GROUP BY year
ORDER BY year;

-- Cast Table -- 

-- 4 — marvel_cast_raw Numeric Validation --

-- 4A — tmdb_id --

SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
             AND TRY_CONVERT(DECIMAL(20,2), tmdb_id) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values
FROM dbo.marvel_cast_raw;

-- 4B — actor_tmdb_id --

SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(actor_tmdb_id)), '') IS NOT NULL
             AND TRY_CONVERT(DECIMAL(20,2), actor_tmdb_id) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values
FROM dbo.marvel_cast_raw;

-- 4C — cast_order --

SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(cast_order)), '') IS NOT NULL
             AND TRY_CONVERT(INT, cast_order) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values
FROM dbo.marvel_cast_raw;

-- 4D — popularity -- 

SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(popularity)), '') IS NOT NULL
             AND TRY_CONVERT(DECIMAL(20,4), popularity) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values
FROM dbo.marvel_cast_raw;

-- Ratings Table -- 

-- 5 — marvel_ratings_raw Numeric Validation -- 

-- 5A — Ratings year -- 

SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(year)), '') IS NOT NULL
             AND TRY_CONVERT(INT, year) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values
FROM dbo.marvel_ratings_raw;

-- 5B — Ratings score -- 

SELECT
    source,
    COUNT(*) AS Record_Count,
    MIN(score) AS Min_Raw_Score,
    MAX(score) AS Max_Raw_Score
FROM dbo.marvel_ratings_raw
GROUP BY source
ORDER BY source;

-- 5C — Validate IMDb Scores -- 

SELECT
    COUNT(*) AS Total_IMDb_Rows,

    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(score)), '') IS NOT NULL
             AND TRY_CONVERT(DECIMAL(5,2), score) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Numeric_Values,

    MIN(
        TRY_CONVERT(DECIMAL(5,2), score)
    ) AS Min_IMDb_Score,

    MAX(
        TRY_CONVERT(DECIMAL(5,2), score)
    ) AS Max_IMDb_Score

FROM dbo.marvel_ratings_raw
WHERE source = 'IMDb';

-- Audit conclusion : All 149 IMDb scores are numerically valid, and the observed range is: 3.20–8.70 -- 

-- 5D — Validate Metacritic Scores -- 

SELECT
    COUNT(*) AS Total_RT_Rows,

    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(score)), '') IS NOT NULL
             AND (
                    RIGHT(LTRIM(RTRIM(score)), 1) <> '%'
                    OR TRY_CONVERT(
                        DECIMAL(5,2),
                        LEFT(
                            LTRIM(RTRIM(score)),
                            CASE
                                WHEN CHARINDEX('%', LTRIM(RTRIM(score))) > 0
                                THEN CHARINDEX('%', LTRIM(RTRIM(score))) - 1
                                ELSE 0
                            END
                        )
                    ) IS NULL
                 )
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Score_Values,

    MIN(
        TRY_CONVERT(
            DECIMAL(5,2),
            CASE
                WHEN CHARINDEX('%', LTRIM(RTRIM(score))) > 0
                THEN LEFT(
                    LTRIM(RTRIM(score)),
                    CHARINDEX('%', LTRIM(RTRIM(score))) - 1
                )
                ELSE NULL
            END
        )
    ) AS Min_RT_Score,

    MAX(
        TRY_CONVERT(
            DECIMAL(5,2),
            CASE
                WHEN CHARINDEX('%', LTRIM(RTRIM(score))) > 0
                THEN LEFT(
                    LTRIM(RTRIM(score)),
                    CHARINDEX('%', LTRIM(RTRIM(score))) - 1
                )
                ELSE NULL
            END
        )
    ) AS Max_RT_Score

FROM dbo.marvel_ratings_raw
WHERE source = 'Rotten Tomatoes';

-- 5F — Validate TMDB Scores -- 

SELECT
    COUNT(*) AS Total_TMDB_Rows,

    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(score)), '') IS NOT NULL
             AND TRY_CONVERT(DECIMAL(10,3), score) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Score_Values,

    MIN(
        TRY_CONVERT(DECIMAL(10,3), score)
    ) AS Min_TMDB_Score,

    MAX(
        TRY_CONVERT(DECIMAL(10,3), score)
    ) AS Max_TMDB_Score

FROM dbo.marvel_ratings_raw
WHERE source = 'TMDB';

-- Overall conclusion : All 554 rating records contain valid, interpretable scores,
-- with no invalid or out-of-range values identified after accounting for each source's specific score format and scale. --

-- Text & Categorical Value Audit -- 

-- Master Table -- 

-- 1A — type Value Audit --

SELECT
    CASE
        WHEN type IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(type)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(type))
    END AS Type_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN type IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(type)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(type))
    END
ORDER BY Record_Count DESC, Type_Value;

-- 1B — rated Value Audit -- 

SELECT
    CASE
        WHEN rated IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(rated)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(rated))
    END AS Rated_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN rated IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(rated)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(rated))
    END
ORDER BY Record_Count DESC, Rated_Value;

-- 1C — genre Value Audit -- 

SELECT
    CASE
        WHEN genre IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(genre)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(genre))
    END AS Genre_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN genre IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(genre)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(genre))
    END
ORDER BY Record_Count DESC, Genre_Value;

-- 1D — director Value Audit -- 

SELECT
    CASE
        WHEN director IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(director)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(director))
    END AS Director_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN director IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(director)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(director))
    END
ORDER BY Record_Count DESC, Director_Value;

-- 1E — writer Value Audit --

SELECT
    CASE
        WHEN writer IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(writer)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(writer))
    END AS Writer_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN writer IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(writer)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(writer))
    END
ORDER BY Record_Count DESC, Writer_Value;

-- 1F — actors Value Audit -- 

SELECT
    CASE
        WHEN actors IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(actors)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(actors))
    END AS Actors_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN actors IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(actors)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(actors))
    END
ORDER BY Record_Count DESC, Actors_Value;

-- 8.1G — plot Value Audit --

SELECT
    CASE
        WHEN plot IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(plot)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(plot))
    END AS Plot_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN plot IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(plot)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(plot))
    END
ORDER BY Record_Count DESC, Plot_Value;

-- 8.1H — language Value Audit -- 

SELECT
    CASE
        WHEN language IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(language)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(language))
    END AS Language_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    CASE
        WHEN language IS NULL THEN '[SQL NULL]'
        WHEN LTRIM(RTRIM(language)) = '' THEN '[BLANK]'
        ELSE LTRIM(RTRIM(language))
    END
ORDER BY Record_Count DESC, Language_Value;

-- Consolidated Text/Categorical Audit --

SELECT
    COUNT(*) AS Total_Rows,

    -- Missing / Blank / Placeholder Counts
    SUM(CASE
        WHEN country IS NULL OR LTRIM(RTRIM(country)) = ''
        THEN 1 ELSE 0
    END) AS Country_Missing,

    SUM(CASE
        WHEN awards IS NULL OR LTRIM(RTRIM(awards)) = ''
        THEN 1 ELSE 0
    END) AS Awards_Missing,

    SUM(CASE
        WHEN poster IS NULL OR LTRIM(RTRIM(poster)) = ''
        THEN 1 ELSE 0
    END) AS Poster_Missing,

    SUM(CASE
        WHEN box_office IS NULL OR LTRIM(RTRIM(box_office)) = ''
        THEN 1 ELSE 0
    END) AS Box_Office_Missing,

    SUM(CASE
        WHEN production IS NULL OR LTRIM(RTRIM(production)) = ''
        THEN 1 ELSE 0
    END) AS Production_Missing,

    SUM(CASE
        WHEN website IS NULL OR LTRIM(RTRIM(website)) = ''
        THEN 1 ELSE 0
    END) AS Website_Missing

FROM dbo.marvel_master_raw;

--- 
SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(country)), '') IS NULL THEN 1 ELSE 0 END) AS country_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(awards)), '') IS NULL THEN 1 ELSE 0 END) AS awards_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(production)), '') IS NULL THEN 1 ELSE 0 END) AS production_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(website)), '') IS NULL THEN 1 ELSE 0 END) AS website_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(mcu_phase)), '') IS NULL THEN 1 ELSE 0 END) AS mcu_phase_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(universe)), '') IS NULL THEN 1 ELSE 0 END) AS universe_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(decade)), '') IS NULL THEN 1 ELSE 0 END) AS decade_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(is_animated)), '') IS NULL THEN 1 ELSE 0 END) AS is_animated_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(is_tv_series)), '') IS NULL THEN 1 ELSE 0 END) AS is_tv_series_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(is_mcu_canon)), '') IS NULL THEN 1 ELSE 0 END) AS is_mcu_canon_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(tmdb_genres)), '') IS NULL THEN 1 ELSE 0 END) AS tmdb_genres_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(top5_cast)), '') IS NULL THEN 1 ELSE 0 END) AS top5_cast_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(directors)), '') IS NULL THEN 1 ELSE 0 END) AS directors_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(producers)), '') IS NULL THEN 1 ELSE 0 END) AS producers_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(composer)), '') IS NULL THEN 1 ELSE 0 END) AS composer_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(tmdb_keywords)), '') IS NULL THEN 1 ELSE 0 END) AS tmdb_keywords_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(collection_name)), '') IS NULL THEN 1 ELSE 0 END) AS collection_name_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(poster_url)), '') IS NULL THEN 1 ELSE 0 END) AS poster_url_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(production_countries)), '') IS NULL THEN 1 ELSE 0 END) AS production_countries_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(spoken_languages)), '') IS NULL THEN 1 ELSE 0 END) AS spoken_languages_missing,

    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(network)), '') IS NULL THEN 1 ELSE 0 END) AS network_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(status)), '') IS NULL THEN 1 ELSE 0 END) AS status_missing,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(tagline)), '') IS NULL THEN 1 ELSE 0 END) AS tagline_missing

FROM dbo.marvel_master_raw;

-- 2B — Categorical Consistency Audit -- 

SELECT
    'mcu_phase' AS Column_Name,
    LTRIM(RTRIM(mcu_phase)) AS Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(mcu_phase))

UNION ALL

SELECT
    'universe',
    LTRIM(RTRIM(universe)),
    COUNT(*)
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(universe))

UNION ALL

SELECT
    'decade',
    LTRIM(RTRIM(decade)),
    COUNT(*)
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(decade))

UNION ALL

SELECT
    'is_animated',
    LTRIM(RTRIM(is_animated)),
    COUNT(*)
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(is_animated))

UNION ALL

SELECT
    'is_tv_series',
    LTRIM(RTRIM(is_tv_series)),
    COUNT(*)
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(is_tv_series))

UNION ALL

SELECT
    'is_mcu_canon',
    LTRIM(RTRIM(is_mcu_canon)),
    COUNT(*)
FROM dbo.marvel_master_raw
GROUP BY LTRIM(RTRIM(is_mcu_canon))

ORDER BY Column_Name, Record_Count DESC, Value;

-- 2C — Remaining Text Fields -- 

SELECT
    Column_Name,
    Placeholder_Value,
    Record_Count
FROM
(
    SELECT 'country' AS Column_Name, LTRIM(RTRIM(country)) AS Placeholder_Value, COUNT(*) AS Record_Count
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(country))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(country))

    UNION ALL

    SELECT 'awards', LTRIM(RTRIM(awards)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(awards))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(awards))

    UNION ALL

    SELECT 'production', LTRIM(RTRIM(production)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(production))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(production))

    UNION ALL

    SELECT 'website', LTRIM(RTRIM(website)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(website))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(website))

    UNION ALL

    SELECT 'tmdb_genres', LTRIM(RTRIM(tmdb_genres)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(tmdb_genres))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(tmdb_genres))

    UNION ALL

    SELECT 'top5_cast', LTRIM(RTRIM(top5_cast)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(top5_cast))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(top5_cast))

    UNION ALL

    SELECT 'directors', LTRIM(RTRIM(directors)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(directors))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(directors))

    UNION ALL

    SELECT 'producers', LTRIM(RTRIM(producers)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(producers))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(producers))

    UNION ALL

    SELECT 'composer', LTRIM(RTRIM(composer)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(composer))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(composer))

    UNION ALL

    SELECT 'tmdb_keywords', LTRIM(RTRIM(tmdb_keywords)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(tmdb_keywords))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(tmdb_keywords))

    UNION ALL

    SELECT 'collection_name', LTRIM(RTRIM(collection_name)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(collection_name))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(collection_name))

    UNION ALL

    SELECT 'poster_url', LTRIM(RTRIM(poster_url)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(poster_url))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(poster_url))

    UNION ALL

    SELECT 'production_countries', LTRIM(RTRIM(production_countries)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(production_countries))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(production_countries))

    UNION ALL

    SELECT 'spoken_languages', LTRIM(RTRIM(spoken_languages)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(spoken_languages))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(spoken_languages))

    UNION ALL

    SELECT 'network', LTRIM(RTRIM(network)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(network))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(network))

    UNION ALL

    SELECT 'status', LTRIM(RTRIM(status)), COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE UPPER(LTRIM(RTRIM(status))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NOT AVAILABLE', '-')
    GROUP BY LTRIM(RTRIM(status))
) AS Placeholder_Audit
ORDER BY Column_Name, Record_Count DESC;

-- Conclusion : The remaining text fields use a single placeholder convention (N/A) rather than multiple inconsistent placeholders 
-- production and website have particularly high missingness (114 records each), while collection_name, awards, and country contain smaller numbers of N/A values. -- 

-- Cross-Column Logical Consistency -- 

-- master table -- 

SELECT
    Check_Name,
    Issue_Count
FROM
(
    /* Check 1: type vs is_tv_series */
    SELECT
        'type vs is_tv_series contradiction' AS Check_Name,
        COUNT(*) AS Issue_Count
    FROM dbo.marvel_master_raw
    WHERE
        (LOWER(LTRIM(RTRIM(type))) = 'series'
         AND TRY_CONVERT(INT, is_tv_series) <> 1)
        OR
        (LOWER(LTRIM(RTRIM(type))) = 'movie'
         AND TRY_CONVERT(INT, is_tv_series) <> 0)

    UNION ALL

    /* Check 2: year vs decade */
    SELECT
        'year vs decade mismatch',
        COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE
        TRY_CONVERT(INT, year) IS NOT NULL
        AND decade IS NOT NULL
        AND LTRIM(RTRIM(decade)) <> ''
        AND LTRIM(RTRIM(decade)) <>
            CONCAT(
                (TRY_CONVERT(INT, year) / 10) * 10,
                's'
            )

    UNION ALL

    /* Check 3: MCU universe vs canon flag */
    SELECT
        'universe vs is_mcu_canon contradiction',
        COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE
        (
            LTRIM(RTRIM(universe)) = 'MCU'
            AND TRY_CONVERT(INT, is_mcu_canon) <> 1
        )
        OR
        (
            LTRIM(RTRIM(universe)) <> 'MCU'
            AND TRY_CONVERT(INT, is_mcu_canon) = 1
        )

    UNION ALL

    /* Check 4: MCU phase vs universe */
    SELECT
        'mcu_phase vs universe contradiction',
        COUNT(*)
    FROM dbo.marvel_master_raw
    WHERE
        (
            LTRIM(RTRIM(mcu_phase)) LIKE 'Phase %'
            AND LTRIM(RTRIM(universe)) <> 'MCU'
        )
        OR
        (
            LTRIM(RTRIM(mcu_phase)) IN ('Non-MCU', 'Pre-MCU')
            AND LTRIM(RTRIM(universe)) = 'MCU'
        )
) AS Consistency_Audit
ORDER BY Check_Name;

-- 2 — Investigate the 29 Records -- 

SELECT
    universe,
    mcu_phase,
    is_mcu_canon,
    type,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE
    (
        LTRIM(RTRIM(mcu_phase)) LIKE 'Phase %'
        AND LTRIM(RTRIM(universe)) <> 'MCU'
    )
    OR
    (
        LTRIM(RTRIM(mcu_phase)) IN ('Non-MCU', 'Pre-MCU')
        AND LTRIM(RTRIM(universe)) = 'MCU'
    )
GROUP BY
    universe,
    mcu_phase,
    is_mcu_canon,
    type
ORDER BY Record_Count DESC;

-- 3 — Identify the Actual 29 Records -- 

SELECT
    tmdb_id,
    title,
    year,
    type,
    universe,
    mcu_phase,
    is_mcu_canon
FROM dbo.marvel_master_raw
WHERE
    (
        LTRIM(RTRIM(mcu_phase)) LIKE 'Phase %'
        AND LTRIM(RTRIM(universe)) <> 'MCU'
    )
    OR
    (
        LTRIM(RTRIM(mcu_phase)) IN ('Non-MCU', 'Pre-MCU')
        AND LTRIM(RTRIM(universe)) = 'MCU'
    )
ORDER BY
    universe,
    mcu_phase,
    year,
    title;

-- 4 — year vs release_date Consistency -- 

SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'marvel_master_raw'
  AND (
        DATA_TYPE IN ('date', 'datetime', 'datetime2', 'smalldatetime')
        OR COLUMN_NAME LIKE '%date%'
        OR COLUMN_NAME LIKE '%release%'
      )
ORDER BY ORDINAL_POSITION;

-- ---- 

SELECT
    tmdb_id,
    title,
    type,
    genre,
    is_animated
FROM dbo.marvel_master_raw
WHERE
    TRY_CONVERT(INT, is_animated) = 1
    AND (
        genre IS NULL
        OR LTRIM(RTRIM(genre)) = ''
        OR LTRIM(RTRIM(genre)) NOT LIKE '%Animation%'
    )
ORDER BY title;

-- 6 — Investigate What If...? -- 

SELECT
    tmdb_id,
    title,
    year,
    type,
    rated,
    runtime_min,
    genre,
    director,
    writer,
    actors,
    plot,
    language,
    country,
    mcu_phase,
    universe,
    is_animated,
    is_tv_series,
    is_mcu_canon
FROM dbo.marvel_master_raw
WHERE title = 'What If...?'
ORDER BY year;

-- Audit conclusion : tmdb_id = 1163055 appears to contain metadata belonging to an unrelated 2023 German short film
-- while being classified as an MCU/animated/canon title. This is a confirmed data-quality anomaly
-- requiring correction or exclusion during the cleaning stage. -- 

-- 7 - Check is_animated vs is_tv_series -- 

SELECT
    is_animated,
    is_tv_series,
    type,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    is_animated,
    is_tv_series,
    type
ORDER BY
    is_animated,
    is_tv_series,
    type;

-- 8 — is_mcu_canon vs mcu_phase vs universe -- 

SELECT
    universe,
    mcu_phase,
    is_mcu_canon,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    universe,
    mcu_phase,
    is_mcu_canon
ORDER BY
    universe,
    mcu_phase,
    is_mcu_canon;

-- Referential Integrity -- 

-- 1 — marvel_cast_raw → marvel_master_raw -- 

SELECT
    COUNT(*) AS Total_Cast_Rows,
    COUNT(DISTINCT c.tmdb_id) AS Distinct_Cast_TMDB_IDs,
    SUM(
        CASE
            WHEN m.tmdb_id IS NULL THEN 1
            ELSE 0
        END
    ) AS Orphan_Cast_Rows,
    COUNT(DISTINCT
        CASE
            WHEN m.tmdb_id IS NULL THEN c.tmdb_id
        END
    ) AS Orphan_Cast_TMDB_IDs
FROM dbo.marvel_cast_raw AS c
LEFT JOIN dbo.marvel_master_raw AS m
    ON c.tmdb_id = m.tmdb_id;

-- 2 — Master → Cast Coverage -- 

SELECT
    COUNT(*) AS Total_Master_Rows,
    COUNT(DISTINCT m.tmdb_id) AS Distinct_Master_TMDB_IDs,
    SUM(
        CASE
            WHEN c.tmdb_id IS NULL THEN 1
            ELSE 0
        END
    ) AS Master_Rows_Without_Cast,
    COUNT(DISTINCT
        CASE
            WHEN c.tmdb_id IS NULL THEN m.tmdb_id
        END
    ) AS Master_TMDB_IDs_Without_Cast
FROM dbo.marvel_master_raw AS m
LEFT JOIN
(
    SELECT DISTINCT tmdb_id
    FROM dbo.marvel_cast_raw
) AS c
    ON m.tmdb_id = c.tmdb_id;

-- 2A — Identify Master Titles Without Cast -- 

SELECT
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon,
    COUNT(*) AS Master_Row_Count
FROM dbo.marvel_master_raw AS m
LEFT JOIN
(
    SELECT DISTINCT tmdb_id
    FROM dbo.marvel_cast_raw
) AS c
    ON m.tmdb_id = c.tmdb_id
WHERE c.tmdb_id IS NULL
GROUP BY
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon
ORDER BY
    m.tmdb_id;

-- 2B — Validate NULL tmdb_id Records -- 

SELECT
    COUNT(*) AS Null_TMDB_ID_Rows,
    COUNT(DISTINCT title) AS Distinct_Titles_With_Null_TMDB_ID
FROM dbo.marvel_master_raw
WHERE tmdb_id IS NULL;


SELECT
    title,
    year,
    type,
    universe,
    is_mcu_canon,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE tmdb_id IS NULL
GROUP BY
    title,
    year,
    type,
    universe,
    is_mcu_canon
ORDER BY
    year,
    title;

-- Conclusion : Exactly 3 distinct valid tmdb_ids exist in the master table without any corresponding cast records.
-- The 46 figure is simply because those 3 IDs occur across multiple master rows due to the duplicate records we've already identified. -- 

-- 2C — Identify the 3 Genuine Unmatched IDs -- 

SELECT
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon,
    COUNT(*) AS Master_Row_Count
FROM dbo.marvel_master_raw AS m
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.marvel_cast_raw AS c
    WHERE c.tmdb_id = m.tmdb_id
)
GROUP BY
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon
ORDER BY
    m.tmdb_id;

-- 2D — Validate the Empty tmdb_id Problem -- 

SELECT
    COUNT(*) AS Empty_TMDB_ID_Rows,
    COUNT(DISTINCT title) AS Distinct_Titles_With_Empty_TMDB_ID
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(tmdb_id)) = '';

SELECT
    title,
    year,
    type,
    universe,
    is_mcu_canon,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(tmdb_id)) = ''
GROUP BY
    title,
    year,
    type,
    universe,
    is_mcu_canon
ORDER BY
    year,
    title;

-- 2E — Audit Empty/NULL tmdb_id in BOTH Tables --

SELECT
    'marvel_master_raw' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE
            WHEN tmdb_id IS NULL
              OR LTRIM(RTRIM(tmdb_id)) = ''
            THEN 1 ELSE 0
        END) AS Null_Or_Empty_TMDB_ID_Rows,
    COUNT(DISTINCT CASE
            WHEN tmdb_id IS NULL
              OR LTRIM(RTRIM(tmdb_id)) = ''
            THEN NULL
            ELSE tmdb_id
        END) AS Valid_Distinct_TMDB_IDs
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'marvel_cast_raw',
    COUNT(*),
    SUM(CASE
            WHEN tmdb_id IS NULL
              OR LTRIM(RTRIM(tmdb_id)) = ''
            THEN 1 ELSE 0
        END),
    COUNT(DISTINCT CASE
            WHEN tmdb_id IS NULL
              OR LTRIM(RTRIM(tmdb_id)) = ''
            THEN NULL
            ELSE tmdb_id
        END)
FROM dbo.marvel_cast_raw;

-- 2F — Correct Master → Cast Referential Integrity -- 

SELECT
    COUNT(DISTINCT m.tmdb_id) AS Valid_Master_TMDB_IDs,
    COUNT(DISTINCT CASE
        WHEN c.tmdb_id IS NOT NULL THEN m.tmdb_id
    END) AS Master_TMDB_IDs_With_Cast,
    COUNT(DISTINCT CASE
        WHEN c.tmdb_id IS NULL THEN m.tmdb_id
    END) AS Master_TMDB_IDs_Without_Cast
FROM dbo.marvel_master_raw AS m
LEFT JOIN
(
    SELECT DISTINCT tmdb_id
    FROM dbo.marvel_cast_raw
) AS c
    ON LTRIM(RTRIM(m.tmdb_id)) = LTRIM(RTRIM(c.tmdb_id))
WHERE
    m.tmdb_id IS NOT NULL
    AND LTRIM(RTRIM(m.tmdb_id)) <> '';

-- 2G — Investigate the 2 Valid Master IDs Without Cast -- 

SELECT
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon,
    m.is_tv_series,
    m.is_animated,
    COUNT(*) AS Master_Row_Count
FROM dbo.marvel_master_raw AS m
WHERE
    m.tmdb_id IN ('241388.0', '318417.0')
GROUP BY
    m.tmdb_id,
    m.title,
    m.year,
    m.type,
    m.universe,
    m.is_mcu_canon,
    m.is_tv_series,
    m.is_animated
ORDER BY
    m.tmdb_id;

-- Key audit findings

-- 1. Master business-key issue — 44 records 🔴

-- marvel_master_raw contains 44 records with empty tmdb_id values.

-- This needs to be addressed during the cleaning/transformation stage.

-- 2. Cast table business keys — clean ✅

-- All 1,628 cast records have valid tmdb_ids.

-- 3. Master → Cast coverage — 98.26% ✅

-- 113 of 115 valid master IDs have cast data.

-- 4. Two legitimate coverage gaps ⚠️

-- Eyes of Wakanda
-- Daredevil: Born Again

-- We'll retain these as missing cast coverage rather than treating them as errors. --

-- 3 — Now Audit marvel_ratings_raw -- 

-- 3A — Ratings Business-Key Quality Audit--

SELECT
    COUNT(*) AS Total_Rating_Rows,

    SUM(CASE
        WHEN title IS NULL OR LTRIM(RTRIM(title)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Title_Rows,

    SUM(CASE
        WHEN year IS NULL OR LTRIM(RTRIM(year)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Year_Rows,

    SUM(CASE
        WHEN source IS NULL OR LTRIM(RTRIM(source)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Source_Rows,

    COUNT(DISTINCT
        CASE
            WHEN title IS NOT NULL
             AND LTRIM(RTRIM(title)) <> ''
             AND year IS NOT NULL
             AND LTRIM(RTRIM(year)) <> ''
            THEN CONCAT(
                LTRIM(RTRIM(title)),
                '|',
                LTRIM(RTRIM(year))
            )
        END
    ) AS Distinct_Title_Year_Keys

FROM dbo.marvel_ratings_raw;

-- 3B — Check Duplicate Rating Sources --

SELECT
    title,
    year,
    source,
    COUNT(*) AS Record_Count
FROM dbo.marvel_ratings_raw
GROUP BY
    title,
    year,
    source
HAVING COUNT(*) > 1
ORDER BY
    Record_Count DESC,
    title,
    year,
    source;

-- 3C — Ratings → Master Referential Integrity -- 

SELECT
    COUNT(*) AS Total_Rating_Rows,

    SUM(
        CASE
            WHEN m.title IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Orphan_Rating_Rows,

    COUNT(DISTINCT
        CASE
            WHEN m.title IS NULL
            THEN CONCAT(
                LTRIM(RTRIM(r.title)),
                '|',
                LTRIM(RTRIM(r.year))
            )
        END
    ) AS Orphan_Title_Year_Keys

FROM dbo.marvel_ratings_raw AS r

LEFT JOIN
(
    SELECT DISTINCT
        LTRIM(RTRIM(title)) AS title,
        LTRIM(RTRIM(year)) AS year
    FROM dbo.marvel_master_raw
) AS m
    ON LTRIM(RTRIM(r.title)) = m.title
    AND LTRIM(RTRIM(r.year)) = m.year;

-- 3D — Master → Ratings Coverage -- 

SELECT
    COUNT(*) AS Total_Master_Title_Year_Keys,
    SUM(
        CASE
            WHEN r.title IS NULL THEN 1
            ELSE 0
        END
    ) AS Master_Title_Year_Without_Ratings
FROM
(
    SELECT DISTINCT
        LTRIM(RTRIM(title)) AS title,
        LTRIM(RTRIM(year)) AS year
    FROM dbo.marvel_master_raw
) AS m
LEFT JOIN
(
    SELECT DISTINCT
        LTRIM(RTRIM(title)) AS title,
        LTRIM(RTRIM(year)) AS year
    FROM dbo.marvel_ratings_raw
) AS r
    ON m.title = r.title
    AND m.year = r.year;

-- 4 — Duplicate Master title + year Business Keys -- 

SELECT
    LTRIM(RTRIM(title)) AS title,
    LTRIM(RTRIM(year)) AS year,
    COUNT(*) AS Record_Count,
    COUNT(DISTINCT tmdb_id) AS Distinct_TMDB_IDs
FROM dbo.marvel_master_raw
GROUP BY
    LTRIM(RTRIM(title)),
    LTRIM(RTRIM(year))
HAVING COUNT(*) > 1
ORDER BY
    Record_Count DESC,
    title,
    year;

-- Cross-Table Content Consistency --

-- 1 — Ratings Year vs Master Year -- 

SELECT
    COUNT(*) AS Total_Rating_Rows,
    SUM(
        CASE
            WHEN TRY_CONVERT(INT, r.year) <> TRY_CONVERT(INT, m.year)
            THEN 1
            ELSE 0
        END
    ) AS Year_Mismatch_Rows
FROM dbo.marvel_ratings_raw AS r
INNER JOIN
(
    SELECT DISTINCT
        LTRIM(RTRIM(title)) AS title,
        LTRIM(RTRIM(year)) AS year
    FROM dbo.marvel_master_raw
) AS m
    ON LTRIM(RTRIM(r.title)) = m.title
    AND LTRIM(RTRIM(r.year)) = m.year;

-- 2 — Ratings Source Coverage -- 

SELECT
    title,
    year,
    COUNT(DISTINCT source) AS Source_Count
FROM dbo.marvel_ratings_raw
GROUP BY
    title,
    year
HAVING COUNT(DISTINCT source) < 4
ORDER BY
    Source_Count,
    title,
    year;

-- 2A — Identify Exactly Which Sources Are Missing -- 

SELECT
    title,
    year,

    MAX(CASE WHEN LOWER(LTRIM(RTRIM(source))) = 'imdb'
        THEN 1 ELSE 0 END) AS Has_IMDb,

    MAX(CASE WHEN LOWER(LTRIM(RTRIM(source))) = 'metacritic'
        THEN 1 ELSE 0 END) AS Has_Metacritic,

    MAX(CASE WHEN LOWER(LTRIM(RTRIM(source))) = 'rotten tomatoes'
        THEN 1 ELSE 0 END) AS Has_Rotten_Tomatoes,

    MAX(CASE WHEN LOWER(LTRIM(RTRIM(source))) = 'tmdb'
        THEN 1 ELSE 0 END) AS Has_TMDb,

    COUNT(DISTINCT source) AS Source_Count

FROM dbo.marvel_ratings_raw
GROUP BY
    title,
    year
HAVING COUNT(DISTINCT source) < 4
ORDER BY
    Source_Count,
    title,
    year;

-- Audit conclusion : The missing rating-source combinations are legitimate source-coverage gaps rather than confirmed data-quality errors. 
-- No cleaning action is required.

-- 2B — Investigate Daredevil: Born Again -- 

SELECT
    'MASTER' AS Source_Table,
    tmdb_id,
    title,
    year,
    type,
    universe,
    is_mcu_canon,
    is_tv_series,
    is_animated
FROM dbo.marvel_master_raw
WHERE title = 'Daredevil: Born Again'

UNION ALL

SELECT
    'RATINGS' AS Source_Table,
    NULL AS tmdb_id,
    title,
    year,
    NULL AS type,
    NULL AS universe,
    NULL AS is_mcu_canon,
    NULL AS is_tv_series,
    NULL AS is_animated
FROM dbo.marvel_ratings_raw
WHERE title = 'Daredevil: Born Again'
ORDER BY
    Source_Table,
    year;

-- 2C — Investigate Both TMDB IDs -- 

SELECT *
FROM dbo.marvel_master_raw
WHERE tmdb_id IN ('202055.0', '3184170.0')
ORDER BY tmdb_id;

-- 2C — Corrected Investigation -- 

SELECT *
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(title)) = 'Daredevil: Born Again'
ORDER BY year, id;

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    genre,
    plot,
    language,
    country,
    mcu_phase,
    universe,
    is_mcu_canon,
    is_tv_series,
    is_animated
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(title)) = 'Daredevil: Born Again'
ORDER BY year;

-- 3 — Rating Score Format Audit -- 

SELECT
    source,
    COUNT(*) AS Record_Count,
    MIN(score) AS Min_Raw_Score,
    MAX(score) AS Max_Raw_Score
FROM dbo.marvel_ratings_raw
GROUP BY source
ORDER BY source;

SELECT
    source,
    score,
    COUNT(*) AS Record_Count
FROM dbo.marvel_ratings_raw
GROUP BY
    source,
    score
ORDER BY
    source,
    score;

-- 3 — Final Conclusion : All available rating scores conform to their respective source formats and valid numerical ranges.
-- No malformed or out-of-range rating values were identified.
-- Missing scores represent source-coverage gaps and should remain missing.

-- 4 — Check for Rating Score/Text Anomalies -- 

SELECT
    source,
    score,
    COUNT(*) AS Record_Count
FROM dbo.marvel_ratings_raw
WHERE
    (
        source = 'IMDb'
        AND TRY_CONVERT(DECIMAL(10,3), score) IS NULL
        AND score IS NOT NULL
    )
    OR
    (
        source = 'TMDB'
        AND TRY_CONVERT(DECIMAL(10,3), score) IS NULL
        AND score IS NOT NULL
    )
    OR
    (
        source = 'Metacritic'
        AND (
            score NOT LIKE '%/100'
            OR TRY_CONVERT(
                DECIMAL(10,3),
                REPLACE(score, '/100', '')
            ) IS NULL
        )
        AND score IS NOT NULL
    )
    OR
    (
        source = 'Rotten Tomatoes'
        AND (
            score NOT LIKE '%\%%' ESCAPE '\'
            OR TRY_CONVERT(
                DECIMAL(10,3),
                REPLACE(score, '%', '')
            ) IS NULL
        )
        AND score IS NOT NULL
    )
GROUP BY
    source,
    score
ORDER BY
    source,
    score;

-- 4A — Properly Separate Missing vs Invalid Scores -- 

SELECT
    source,

    COUNT(*) AS Total_Rows,

    SUM(CASE
        WHEN score IS NULL
          OR LTRIM(RTRIM(score)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Score_Rows,

    SUM(CASE
        WHEN score IS NOT NULL
         AND LTRIM(RTRIM(score)) <> ''
         AND (
                (source IN ('IMDb', 'TMDB')
                 AND TRY_CONVERT(DECIMAL(10,3), LTRIM(RTRIM(score))) IS NULL)

             OR (source = 'Metacritic'
                 AND (
                     LTRIM(RTRIM(score)) NOT LIKE '%/100'
                     OR TRY_CONVERT(
                            DECIMAL(10,3),
                            REPLACE(LTRIM(RTRIM(score)), '/100', '')
                        ) IS NULL
                 ))

             OR (source = 'Rotten Tomatoes'
                 AND (
                     LTRIM(RTRIM(score)) NOT LIKE '%[%]'
                     OR TRY_CONVERT(
                            DECIMAL(10,3),
                            REPLACE(LTRIM(RTRIM(score)), '%', '')
                        ) IS NULL
                 ))
             )
        THEN 1 ELSE 0
    END) AS Invalid_NonBlank_Score_Rows

FROM dbo.marvel_ratings_raw
GROUP BY source
ORDER BY source;

-- 5 — Validate Numerical Score Ranges -- 

SELECT
    source,
    COUNT(*) AS Valid_Score_Rows,
    SUM(
        CASE
            WHEN source IN ('IMDb', 'TMDB')
                 AND (
                     TRY_CONVERT(DECIMAL(10,3), LTRIM(RTRIM(score))) < 0
                     OR TRY_CONVERT(DECIMAL(10,3), LTRIM(RTRIM(score))) > 10
                 )
            THEN 1

            WHEN source = 'Metacritic'
                 AND (
                     TRY_CONVERT(
                         DECIMAL(10,3),
                         REPLACE(LTRIM(RTRIM(score)), '/100', '')
                     ) < 0
                     OR TRY_CONVERT(
                         DECIMAL(10,3),
                         REPLACE(LTRIM(RTRIM(score)), '/100', '')
                     ) > 100
                 )
            THEN 1

            WHEN source = 'Rotten Tomatoes'
                 AND (
                     TRY_CONVERT(
                         DECIMAL(10,3),
                         REPLACE(LTRIM(RTRIM(score)), '%', '')
                     ) < 0
                     OR TRY_CONVERT(
                         DECIMAL(10,3),
                         REPLACE(LTRIM(RTRIM(score)), '%', '')
                     ) > 100
                 )
            THEN 1

            ELSE 0
        END
    ) AS Out_Of_Range_Scores

FROM dbo.marvel_ratings_raw
WHERE score IS NOT NULL
  AND LTRIM(RTRIM(score)) <> ''
GROUP BY source
ORDER BY source;

-- 6 — Check Rating Source Naming Consistency -- 

SELECT
    source,
    COUNT(*) AS Record_Count
FROM dbo.marvel_ratings_raw
GROUP BY source
ORDER BY Record_Count DESC;

-- Master Data Consistency Audit -- 

-- 1 — type vs is_tv_series -- 

SELECT
    type,
    is_tv_series,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    type,
    is_tv_series
ORDER BY
    type,
    is_tv_series;

-- 1A — Investigate N/A Type Records ---

SELECT
    title,
    year,
    type,
    is_tv_series,
    is_animated,
    universe,
    is_mcu_canon,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(type)) = 'N/A'
ORDER BY
    year,
    title;

-- 1B — Quantify the Logical Inconsistency -- 

SELECT
    COUNT(*) AS NA_Type_Rows,

    SUM(CASE
        WHEN
            LTRIM(RTRIM(title)) LIKE '%Season%'
            OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
            OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
        THEN 1
        ELSE 0
    END) AS Title_Indicates_Series,

    SUM(CASE
        WHEN is_tv_series = 1
        THEN 1
        ELSE 0
    END) AS Already_Marked_TV_Series,

    SUM(CASE
        WHEN
            (
                LTRIM(RTRIM(title)) LIKE '%Season%'
                OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
                OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
            )
            AND is_tv_series = 0
        THEN 1
        ELSE 0
    END) AS Potential_TV_Series_Mismatch

FROM dbo.marvel_master_raw
WHERE
    type IS NULL
    OR LTRIM(RTRIM(type)) = ''
    OR LTRIM(RTRIM(type)) = 'N/A';

-- 1C — Get the Exact 40 Potential Mismatches -- 

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    is_tv_series,
    is_animated,
    universe,
    is_mcu_canon,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE
    (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
    )
    AND is_tv_series = 0
ORDER BY
    year,
    title;

-- 1D — Investigate the Remaining 7 N/A Type Records -- 

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    is_tv_series,
    is_animated,
    universe,
    is_mcu_canon,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE
    (type IS NULL
     OR LTRIM(RTRIM(type)) = ''
     OR LTRIM(RTRIM(type)) = 'N/A')
    AND NOT (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
    )
ORDER BY
    year,
    title;

-- 1E — Confirm Mutant X -- 

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    genre,
    plot,
    universe,
    is_mcu_canon,
    is_tv_series,
    is_animated,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(title)) = 'Mutant X';

-- 2 — is_animated vs Content Classification -- 

SELECT
    is_animated,
    type,
    is_tv_series,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    is_animated,
    type,
    is_tv_series
ORDER BY
    is_animated,
    type,
    is_tv_series;

-- 2A — Check Missing is_animated -- 

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE
        WHEN is_animated IS NULL THEN 1
        ELSE 0
    END) AS Null_Is_Animated_Rows,
    SUM(CASE
        WHEN is_animated NOT IN (0, 1)
             AND is_animated IS NOT NULL
        THEN 1
        ELSE 0
    END) AS Invalid_Is_Animated_Rows
FROM dbo.marvel_master_raw;

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    is_tv_series,
    is_animated,
    universe,
    is_mcu_canon,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE is_animated IS NULL
   OR is_animated NOT IN (0, 1)
ORDER BY year, title;

-- 2B — Reconcile is_animated Counts -- 

SELECT
    is_animated,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY is_animated
ORDER BY is_animated;

SELECT
    is_tv_series,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY is_tv_series
ORDER BY is_tv_series;

-- 2C — Identify the 6 Animated Records -- 

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    is_tv_series,
    is_animated,
    universe,
    is_mcu_canon,
    mcu_phase
FROM dbo.marvel_master_raw
WHERE is_animated = 1
ORDER BY year, title;

-- 3 — universe vs is_mcu_canon -- 

SELECT
    universe,
    is_mcu_canon,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    universe,
    is_mcu_canon
ORDER BY
    universe,
    is_mcu_canon;

-- 3A — Check Universe Completeness -- 

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE
        WHEN universe IS NULL
          OR LTRIM(RTRIM(universe)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Universe_Rows,

    SUM(CASE
        WHEN universe NOT IN (
            'MCU',
            'Pre-MCU',
            'Fox / X-Men',
            'Sony / Spider-Man',
            'Netflix Marvel'
        )
        AND universe IS NOT NULL
        AND LTRIM(RTRIM(universe)) <> ''
        THEN 1 ELSE 0
    END) AS Unexpected_Universe_Rows

FROM dbo.marvel_master_raw;


/* =========================================================
             CONSOLIDATED MASTER LOGICAL AUDIT
   ========================================================= */

SELECT
    'Total Master Rows' AS Audit_Check,
    COUNT(*) AS Issue_Count
FROM dbo.marvel_master_raw

UNION ALL

/* 1. Invalid is_tv_series values */
SELECT
    'Invalid is_tv_series values',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE is_tv_series NOT IN (0, 1)
   OR is_tv_series IS NULL

UNION ALL

/* 2. Invalid is_animated values */
SELECT
    'Invalid is_animated values',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE is_animated NOT IN (0, 1)
   OR is_animated IS NULL

UNION ALL

/* 3. Invalid is_mcu_canon values */
SELECT
    'Invalid is_mcu_canon values',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE is_mcu_canon NOT IN (0, 1)
   OR is_mcu_canon IS NULL

UNION ALL

/* 4. Non-MCU universe incorrectly marked canon */
SELECT
    'Non-MCU universe marked MCU canon',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE universe <> 'MCU'
  AND is_mcu_canon = 1

UNION ALL

/* 5. MCU universe incorrectly marked non-canon */
SELECT
    'MCU universe marked non-canon',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE universe = 'MCU'
  AND is_mcu_canon = 0

UNION ALL

/* 6. Non-MCU universe carrying an MCU phase */
SELECT
    'Non-MCU universe with MCU phase',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE universe <> 'MCU'
  AND mcu_phase NOT IN ('Pre-MCU', 'Non-MCU', 'N/A')
  AND mcu_phase IS NOT NULL

UNION ALL

/* 7. MCU records without an MCU phase */
SELECT
    'MCU records without MCU phase',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE universe = 'MCU'
  AND (
        mcu_phase IS NULL
        OR LTRIM(RTRIM(mcu_phase)) IN ('', 'N/A', 'Non-MCU')
      )

UNION ALL

/* 8. TV-series indicators with is_tv_series = 0
      Includes the confirmed Mutant X exception */
SELECT
    'Obvious TV-series title but is_tv_series = 0',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE is_tv_series = 0
  AND (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
        OR LTRIM(RTRIM(title)) = 'Mutant X'
      )

UNION ALL

/* 9. Series type but TV flag = 0 */
SELECT
    'type = series but is_tv_series <> 1',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM([type])) = 'series'
  AND is_tv_series <> 1

UNION ALL

/* 10. Movie type but TV flag = 1 */
SELECT
    'type = movie but is_tv_series = 1',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM([type])) = 'movie'
  AND is_tv_series = 1

UNION ALL

/* 11. Animated content marked as TV based on obvious title */
SELECT
    'Animated TV/season title with is_tv_series = 0',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE is_animated = 1
  AND is_tv_series = 0
  AND (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
      )

UNION ALL

/* 12. Missing type */
SELECT
    'Missing/N-A type',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE [type] IS NULL
   OR LTRIM(RTRIM([type])) IN ('', 'N/A')

UNION ALL

/* 13. Missing universe */
SELECT
    'Missing universe',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE universe IS NULL
   OR LTRIM(RTRIM(universe)) = ''

UNION ALL

/* 14. Year outside plausible dataset range */
SELECT
    'Year outside 1900-2100',
    COUNT(*)
FROM dbo.marvel_master_raw
WHERE year IS NULL
   OR year < 1900
   OR year > 2100

ORDER BY
    Audit_Check;

-- Checking the 25 MCU phase issues and 4 non-MCU phase issues -- 

SELECT
    id,
    tmdb_id,
    title,
    year,
    type,
    universe,
    mcu_phase,
    is_mcu_canon,
    is_tv_series,
    is_animated
FROM dbo.marvel_master_raw
WHERE
    (universe = 'MCU'
     AND (
            mcu_phase IS NULL
            OR LTRIM(RTRIM(mcu_phase)) IN ('', 'N/A', 'Non-MCU')
         ))
    OR
    (universe <> 'MCU'
     AND mcu_phase NOT IN ('Pre-MCU', 'Non-MCU', 'N/A')
     AND mcu_phase IS NOT NULL)
ORDER BY
    universe,
    year,
    title;