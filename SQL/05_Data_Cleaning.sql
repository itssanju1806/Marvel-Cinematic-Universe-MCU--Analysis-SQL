
-- Create the Clean Master Table -- 

IF OBJECT_ID('dbo.marvel_master_clean', 'U') IS NOT NULL
    DROP TABLE dbo.marvel_master_clean;

SELECT *
INTO dbo.marvel_master_clean
FROM dbo.marvel_master_raw;

/* =========================================================
   STEP 1 — CLEAN CONFIRMED TV-SERIES CLASSIFICATIONS
   ========================================================= */

BEGIN TRANSACTION;

UPDATE dbo.marvel_master_clean
SET
    type = 'series',
    is_tv_series = 1
WHERE
    is_tv_series = 0
    AND
    (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
        OR LTRIM(RTRIM(title)) = 'Mutant X'
    );

SELECT @@ROWCOUNT AS Rows_Updated;

COMMIT TRANSACTION;

/* =========================================================
   STEP 2 — VALIDATE TV-SERIES CLEANING
   ========================================================= */

SELECT
    'Obvious TV titles still marked is_tv_series = 0' AS Audit_Check,
    COUNT(*) AS Issue_Count
FROM dbo.marvel_master_clean
WHERE
    is_tv_series = 0
    AND
    (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
        OR LTRIM(RTRIM(title)) = 'Mutant X'
    )

UNION ALL

SELECT
    'type = series but is_tv_series <> 1',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE
    LTRIM(RTRIM(type)) = 'series'
    AND is_tv_series <> 1

UNION ALL

SELECT
    'type = movie but is_tv_series = 1',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE
    LTRIM(RTRIM(type)) = 'movie'
    AND is_tv_series = 1;

-- Inspecting the current phase distribution after our TV cleanup -- 

SELECT
    universe,
    mcu_phase,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_clean
GROUP BY
    universe,
    mcu_phase
ORDER BY
    universe,
    mcu_phase;

/* =========================================================
   STEP 2A — IDENTIFY PHASE/UNIVERSE ISSUES
   ========================================================= */

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
FROM dbo.marvel_master_clean
WHERE
       (universe = 'MCU' AND mcu_phase = 'Non-MCU')
    OR (universe <> 'MCU' AND mcu_phase = 'Phase 5/6')
ORDER BY
    universe,
    year,
    title;

/* =========================================================
   STEP 3 — CORRECT NON-MCU RECORDS WITH MCU PHASE
   ========================================================= */

BEGIN TRANSACTION;

UPDATE dbo.marvel_master_clean
SET mcu_phase = 'Non-MCU'
WHERE
    universe <> 'MCU'
    AND mcu_phase = 'Phase 5/6';

SELECT @@ROWCOUNT AS Rows_Updated;

COMMIT TRANSACTION;

/* =========================================================
   STEP 4 — FINAL CLEAN MASTER VALIDATION
   ========================================================= */

SELECT
    'Total Rows' AS Audit_Check,
    COUNT(*) AS Result
FROM dbo.marvel_master_clean

UNION ALL

SELECT
    'Invalid is_tv_series',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE is_tv_series IS NULL
   OR is_tv_series NOT IN (0,1)

UNION ALL

SELECT
    'Invalid is_animated',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE is_animated IS NULL
   OR is_animated NOT IN (0,1)

UNION ALL

SELECT
    'Invalid is_mcu_canon',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE is_mcu_canon IS NULL
   OR is_mcu_canon NOT IN (0,1)

UNION ALL

SELECT
    'Missing Universe',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe IS NULL
   OR LTRIM(RTRIM(universe)) = ''

UNION ALL

SELECT
    'MCU marked non-canon',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe = 'MCU'
  AND is_mcu_canon = 0

UNION ALL

SELECT
    'Non-MCU marked canon',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe <> 'MCU'
  AND is_mcu_canon = 1

UNION ALL

SELECT
    'Movie marked TV series',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE LTRIM(RTRIM(type)) = 'movie'
  AND is_tv_series = 1

UNION ALL

SELECT
    'Series not marked TV series',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE LTRIM(RTRIM(type)) = 'series'
  AND is_tv_series <> 1

UNION ALL

SELECT
    'Obvious TV title still not marked TV',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE is_tv_series = 0
  AND (
        LTRIM(RTRIM(title)) LIKE '%Season%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series%'
        OR LTRIM(RTRIM(title)) LIKE '%TV Series)%'
        OR LTRIM(RTRIM(title)) = 'Mutant X'
      )

UNION ALL

SELECT
    'Non-MCU with MCU Phase',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe <> 'MCU'
  AND mcu_phase LIKE 'Phase%'

UNION ALL

SELECT
    'Year outside valid range',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE year IS NULL
   OR year < 1900
   OR year > 2100;

-- In the audit step we found that Cast and Ratings table is clean, hence we are only creating clean tables at this age --

/* =========================================================
   STEP 5 — CREATE CLEAN RATINGS & CAST TABLES
   ========================================================= */

------------------------------------------------------------
-- 1. Create Clean Ratings Table
------------------------------------------------------------

IF OBJECT_ID('dbo.marvel_ratings_clean', 'U') IS NOT NULL
    DROP TABLE dbo.marvel_ratings_clean;

SELECT *
INTO dbo.marvel_ratings_clean
FROM dbo.marvel_ratings_raw;


/* =========================================================
   STEP 5A — STANDARDIZE RATING SCORES
   ========================================================= */

BEGIN TRANSACTION;

------------------------------------------------------------
-- IMDb & TMDB
-- Already stored as numeric text
------------------------------------------------------------

UPDATE dbo.marvel_ratings_clean
SET score = LTRIM(RTRIM(score))
WHERE source IN ('IMDb', 'TMDB')
  AND score IS NOT NULL;


------------------------------------------------------------
-- Metacritic
-- Convert: 65/100 → 65
------------------------------------------------------------

UPDATE dbo.marvel_ratings_clean
SET score = REPLACE(
                LTRIM(RTRIM(score)),
                '/100',
                ''
            )
WHERE source = 'Metacritic'
  AND score IS NOT NULL;


------------------------------------------------------------
-- Rotten Tomatoes
-- Convert: 90% → 90
------------------------------------------------------------

UPDATE dbo.marvel_ratings_clean
SET score = REPLACE(
                LTRIM(RTRIM(score)),
                '%',
                ''
            )
WHERE source = 'Rotten Tomatoes'
  AND score IS NOT NULL;

SELECT @@ROWCOUNT AS Last_Update_Row_Count;

COMMIT TRANSACTION;

/* =========================================================
   STEP 5B — VALIDATE SCORES BEFORE DATA TYPE CONVERSION
   ========================================================= */

SELECT
    source AS Rating_Source,
    COUNT(*) AS Invalid_Score_Count
FROM dbo.marvel_ratings_clean
WHERE score IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), score) IS NULL
GROUP BY
    source
ORDER BY
    source;

/* =========================================================
   STEP 5C — IDENTIFYING THE PLACEHOLDER
   ========================================================= */

SELECT
    source AS Rating_Source,
    COUNT(*) AS Total_Rows,
    COUNT(score) AS Non_Null_Scores,
    SUM(
        CASE
            WHEN score IS NOT NULL
             AND TRY_CONVERT(DECIMAL(10,2), score) IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Non_Null_Scores
FROM dbo.marvel_ratings_clean
GROUP BY source
ORDER BY source;

-------------------------

SELECT
    source AS Rating_Source,
    score AS Score_Value,
    COUNT(*) AS Record_Count
FROM dbo.marvel_ratings_clean
WHERE TRY_CONVERT(DECIMAL(10,2), score) IS NULL
GROUP BY
    source,
    score
ORDER BY
    source,
    Record_Count DESC;

-----------

SELECT
    source AS Rating_Source,
    COUNT(*) AS Blank_Score_Rows
FROM dbo.marvel_ratings_clean
WHERE score IS NOT NULL
  AND LTRIM(RTRIM(score)) = ''
GROUP BY source
ORDER BY source;

/* =========================================================
   STEP 5D — CONVERT BLANK SCORES TO NULL
   ========================================================= */

UPDATE dbo.marvel_ratings_clean
SET score = NULL
WHERE score IS NOT NULL
  AND LTRIM(RTRIM(score)) = '';

-- Confirmation check

SELECT
    source AS Rating_Source,
    COUNT(*) AS Total_Rows,
    COUNT(score) AS Non_Null_Scores
FROM dbo.marvel_ratings_clean
GROUP BY source
ORDER BY source;

-- Verifying the actual distinct formats -- 

SELECT DISTINCT
    source,
    score
FROM dbo.marvel_ratings_clean
WHERE score IS NOT NULL
ORDER BY
    source,
    score;

-- Validation to make sure every non-NULL score is convertible --

SELECT
    source AS Rating_Source,
    COUNT(*) AS Invalid_Score_Count
FROM dbo.marvel_ratings_clean
WHERE score IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), score) IS NULL
GROUP BY source
ORDER BY source;

/* =========================================================
   STEP 5E — CONVERT RATING SCORE TO NUMERIC
   ========================================================= */

ALTER TABLE dbo.marvel_ratings_clean
ALTER COLUMN score DECIMAL(10,2) NULL;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'marvel_ratings_clean'
  AND COLUMN_NAME = 'score';

/* =========================================================
   FINAL RATINGS CLEANING VALIDATION
   ========================================================= */

SELECT
    source AS Rating_Source,
    COUNT(*) AS Total_Rows,
    COUNT(score) AS Rated_Rows,
    COUNT(*) - COUNT(score) AS Missing_Score_Rows,
    MIN(score) AS Minimum_Score,
    MAX(score) AS Maximum_Score,
    CAST(AVG(score) AS DECIMAL(10,2)) AS Average_Score
FROM dbo.marvel_ratings_clean
GROUP BY source
ORDER BY source;

------------------------------------------------------------
-- 2. Create Clean Cast Table
------------------------------------------------------------

IF OBJECT_ID('dbo.marvel_cast_clean', 'U') IS NOT NULL
    DROP TABLE dbo.marvel_cast_clean;

SELECT *
INTO dbo.marvel_cast_clean
FROM dbo.marvel_cast_raw;


------------------------------------------------------------
-- 3. Confirm Row Counts
------------------------------------------------------------

SELECT
    'marvel_master_clean' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM dbo.marvel_master_clean

UNION ALL

SELECT
    'marvel_ratings_clean',
    COUNT(*)
FROM dbo.marvel_ratings_clean

UNION ALL

SELECT
    'marvel_cast_clean',
    COUNT(*)
FROM dbo.marvel_cast_clean;

/* =========================================================
   STEP 6 — FINAL CROSS-TABLE INTEGRITY VALIDATION
   ========================================================= */

------------------------------------------------------------
-- 1. Ratings → Master orphan check
------------------------------------------------------------

SELECT
    'Ratings rows without matching Master title/year' AS Audit_Check,
    COUNT(*) AS Issue_Count
FROM dbo.marvel_ratings_clean r
LEFT JOIN dbo.marvel_master_clean m
    ON LTRIM(RTRIM(r.title)) = LTRIM(RTRIM(m.title))
   AND TRY_CONVERT(INT, r.year) = TRY_CONVERT(INT, m.year)
WHERE m.id IS NULL

UNION ALL

------------------------------------------------------------
-- 2. Cast → Master orphan check
------------------------------------------------------------

SELECT
    'Cast rows without matching Master TMDB ID',
    COUNT(*)
FROM dbo.marvel_cast_clean c
LEFT JOIN dbo.marvel_master_clean m
    ON TRY_CONVERT(DECIMAL(18,1), c.tmdb_id)
     = TRY_CONVERT(DECIMAL(18,1), m.tmdb_id)
WHERE m.tmdb_id IS NULL

UNION ALL

------------------------------------------------------------
-- 3. Duplicate Master title/year keys
------------------------------------------------------------

SELECT
    'Duplicate Master title/year keys',
    COUNT(*)
FROM (
    SELECT
        LTRIM(RTRIM(title)) AS title,
        TRY_CONVERT(INT, year) AS year
    FROM dbo.marvel_master_clean
    GROUP BY
        LTRIM(RTRIM(title)),
        TRY_CONVERT(INT, year)
    HAVING COUNT(*) > 1
) d

UNION ALL

------------------------------------------------------------
-- 4. Duplicate Rating title/year/source keys
------------------------------------------------------------

SELECT
    'Duplicate Rating title/year/source keys',
    COUNT(*)
FROM (
    SELECT
        LTRIM(RTRIM(title)) AS title,
        TRY_CONVERT(INT, year) AS year,
        LTRIM(RTRIM(source)) AS source
    FROM dbo.marvel_ratings_clean
    GROUP BY
        LTRIM(RTRIM(title)),
        TRY_CONVERT(INT, year),
        LTRIM(RTRIM(source))
    HAVING COUNT(*) > 1
) d

UNION ALL

------------------------------------------------------------
-- 5. Invalid Rating Scores
------------------------------------------------------------

SELECT
    'Invalid Rating Scores',
    COUNT(*)
FROM dbo.marvel_ratings_clean
WHERE
       (source = 'IMDb'
        AND score IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), score) NOT BETWEEN 0 AND 10)

    OR (source = 'TMDB'
        AND score IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), score) NOT BETWEEN 0 AND 10)

    OR (source IN ('Metacritic', 'Rotten Tomatoes')
        AND score IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), score) NOT BETWEEN 0 AND 100)

UNION ALL

------------------------------------------------------------
-- 6. Invalid Master classification flags
------------------------------------------------------------

SELECT
    'Invalid Master classification flags',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE
       is_tv_series NOT IN (0,1)
    OR is_animated NOT IN (0,1)
    OR is_mcu_canon NOT IN (0,1)

UNION ALL

------------------------------------------------------------
-- 7. Missing Master Universe
------------------------------------------------------------

SELECT
    'Missing Master Universe',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe IS NULL
   OR LTRIM(RTRIM(universe)) = ''

UNION ALL

------------------------------------------------------------
-- 8. Non-MCU with MCU Phase
------------------------------------------------------------

SELECT
    'Non-MCU records with MCU Phase',
    COUNT(*)
FROM dbo.marvel_master_clean
WHERE universe <> 'MCU'
  AND mcu_phase LIKE 'Phase%'

ORDER BY
    Audit_Check;


