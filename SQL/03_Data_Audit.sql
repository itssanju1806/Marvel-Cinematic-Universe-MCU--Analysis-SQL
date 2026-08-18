USE Marvel_SQL_Analysis;

-- DATA AUDIT — STEP 1: Table & Schema Audit --

-- Record Count Validation -- 

SELECT COUNT(*) AS Total_Movies
FROM marvel_master_raw;

SELECT COUNT(*) AS Total_Cast
FROM marvel_cast_raw;

SELECT COUNT(*) AS Total_Ratings
FROM marvel_ratings_raw;

-- 1.1 Confirm the three tables -- 

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN (
    'marvel_master_raw',
    'marvel_cast_raw',
    'marvel_ratings_raw'
)
ORDER BY TABLE_NAME;

-- 1.2 Check column count for each table --

SELECT 
    TABLE_NAME,
    COUNT(*) AS Column_Count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'marvel_master_raw',
    'marvel_cast_raw',
    'marvel_ratings_raw'
)
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

-- 1.3 Inspect complete schema -- 

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'marvel_master_raw',
    'marvel_cast_raw',
    'marvel_ratings_raw'
)
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

-- DATA AUDIT — STEP 2: Row Count Audit -- 

-- Verify the imported record counts. --

SELECT 
    'marvel_master_raw' AS Table_Name,
    COUNT(*) AS Row_Count
FROM dbo.marvel_master_raw

UNION ALL

SELECT 
    'marvel_cast_raw',
    COUNT(*)
FROM dbo.marvel_cast_raw

UNION ALL

SELECT 
    'marvel_ratings_raw',
    COUNT(*)
FROM dbo.marvel_ratings_raw;

-- DATA AUDIT — STEP 3: Preview the Raw Data -- 

SELECT TOP 10 *
FROM dbo.marvel_master_raw;

SELECT TOP 10 *
FROM dbo.marvel_cast_raw;

SELECT TOP 10 *
FROM dbo.marvel_ratings_raw;

-- DATA AUDIT — STEP 4: NULL Audit --

-- NULL Audit - Master -- 

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL +
    'SELECT ''' + COLUMN_NAME + ''' AS Column_Name, ' +
    'SUM(CASE 
        WHEN [' + COLUMN_NAME + '] IS NULL
          OR LTRIM(RTRIM([' + COLUMN_NAME + '])) = ''''
          OR UPPER(LTRIM(RTRIM([' + COLUMN_NAME + ']))) IN (''NULL'', ''N/A'', ''NA'', ''NONE'', ''UNKNOWN'')
        THEN 1 ELSE 0 
    END) AS Missing_Count ' +
    'FROM dbo.marvel_master_raw ' +
    'UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'marvel_master_raw'
  AND TABLE_SCHEMA = 'dbo';

SET @SQL = LEFT(@SQL, LEN(@SQL) - 10);

EXEC sp_executesql @SQL;

-- NULL audit — Cast --

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN tmdb_id IS NULL THEN 1 ELSE 0 END) AS tmdb_id_nulls,
    SUM(CASE WHEN actor_name IS NULL THEN 1 ELSE 0 END) AS actor_name_nulls,
    SUM(CASE WHEN character IS NULL THEN 1 ELSE 0 END) AS character_nulls,
    SUM(CASE WHEN cast_order IS NULL THEN 1 ELSE 0 END) AS cast_order_nulls,
    SUM(CASE WHEN actor_tmdb_id IS NULL THEN 1 ELSE 0 END) AS actor_tmdb_id_nulls,
    SUM(CASE WHEN popularity IS NULL THEN 1 ELSE 0 END) AS popularity_nulls,
    SUM(CASE WHEN profile_path IS NULL THEN 1 ELSE 0 END) AS profile_path_nulls
FROM dbo.marvel_cast_raw;

-- NULL audit — Ratings --

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN source IS NULL THEN 1 ELSE 0 END) AS source_nulls,
    SUM(CASE WHEN score IS NULL THEN 1 ELSE 0 END) AS score_nulls
FROM dbo.marvel_ratings_raw;

-- DATA AUDIT — STEP 5: Blank / Empty String Audit --

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL +
    'SELECT 
        ''' + TABLE_NAME + ''' AS Table_Name,
        ''' + COLUMN_NAME + ''' AS Column_Name,

        SUM(CASE 
            WHEN [' + COLUMN_NAME + '] IS NULL 
            THEN 1 ELSE 0 
        END) AS SQL_NULL_Count,

        SUM(CASE 
            WHEN [' + COLUMN_NAME + '] IS NOT NULL
             AND LTRIM(RTRIM([' + COLUMN_NAME + '])) = ''''
            THEN 1 ELSE 0 
        END) AS Blank_or_Whitespace_Count,

        SUM(CASE 
            WHEN UPPER(LTRIM(RTRIM([' + COLUMN_NAME + ']))) IN
                (''NULL'', ''N/A'', ''NA'', ''NONE'', ''UNKNOWN'')
            THEN 1 ELSE 0 
        END) AS Text_Missing_Count,

        SUM(CASE 
            WHEN [' + COLUMN_NAME + '] IS NULL
              OR LTRIM(RTRIM([' + COLUMN_NAME + '])) = ''''
              OR UPPER(LTRIM(RTRIM([' + COLUMN_NAME + ']))) IN
                    (''NULL'', ''N/A'', ''NA'', ''NONE'', ''UNKNOWN'')
            THEN 1 ELSE 0 
        END) AS Total_Missing_Count

    FROM dbo.' + TABLE_NAME + '
    UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'marvel_master_raw',
      'marvel_cast_raw',
      'marvel_ratings_raw'
  );

SET @SQL = LEFT(@SQL, LEN(@SQL) - 10);

EXEC sp_executesql @SQL;

-- DATA AUDIT — STEP 6: Duplicate Audit --

-- Master -- 

DECLARE @SQL NVARCHAR(MAX);

SELECT @SQL =
'
SELECT
    ''marvel_master_raw'' AS Table_Name,
    COUNT(*) AS Duplicate_Group_Count,
    COALESCE(SUM(Duplicate_Count - 1), 0) AS Duplicate_Row_Count
FROM
(
    SELECT
        COUNT(*) AS Duplicate_Count
    FROM dbo.marvel_master_raw
    GROUP BY ' +
    STRING_AGG('[' + COLUMN_NAME + ']', ', ') +
'
    HAVING COUNT(*) > 1
) D;
'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'marvel_master_raw';

EXEC sp_executesql @SQL;

-- Cast --

DECLARE @SQL NVARCHAR(MAX);

SELECT @SQL =
'
SELECT
    ''marvel_cast_raw'' AS Table_Name,
    COUNT(*) AS Duplicate_Group_Count,
    COALESCE(SUM(Duplicate_Count - 1), 0) AS Duplicate_Row_Count
FROM
(
    SELECT
        COUNT(*) AS Duplicate_Count
    FROM dbo.marvel_cast_raw
    GROUP BY ' +
    STRING_AGG('[' + COLUMN_NAME + ']', ', ') +
'
    HAVING COUNT(*) > 1
) D;
'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'marvel_cast_raw';

EXEC sp_executesql @SQL;

-- Ratings -- 

DECLARE @SQL NVARCHAR(MAX);

SELECT @SQL =
'
SELECT
    ''marvel_ratings_raw'' AS Table_Name,
    COUNT(*) AS Duplicate_Group_Count,
    COALESCE(SUM(Duplicate_Count - 1), 0) AS Duplicate_Row_Count
FROM
(
    SELECT
        COUNT(*) AS Duplicate_Count
    FROM dbo.marvel_ratings_raw
    GROUP BY ' +
    STRING_AGG('[' + COLUMN_NAME + ']', ', ') +
'
    HAVING COUNT(*) > 1
) D;
'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'marvel_ratings_raw';

EXEC sp_executesql @SQL;

-- Business-Key Duplicate Audit --

-- 1. marvel_master_raw --

SELECT
    title,
    year,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
GROUP BY
    title,
    year
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-- 2. marvel_cast_raw -- 

SELECT
    title,
    year,
    actor_name,
    character,
    COUNT(*) AS Record_Count
FROM dbo.marvel_cast_raw
GROUP BY
    title,
    year,
    actor_name,
    character
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-- 3. marvel_ratings_raw --

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
ORDER BY Record_Count DESC;

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'marvel_master_raw',
      'marvel_cast_raw',
      'marvel_ratings_raw'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

-- STEP 6 — BUSINESS-KEY DUPLICATE AUDIT --

SELECT
    'id' AS Key_Type,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT id) AS Distinct_Values,
    COUNT(*) - COUNT(DISTINCT id) AS Duplicate_Count
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'imdb_id',
    COUNT(*),
    COUNT(DISTINCT imdb_id),
    COUNT(*) - COUNT(DISTINCT imdb_id)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'tmdb_id',
    COUNT(*),
    COUNT(DISTINCT tmdb_id),
    COUNT(*) - COUNT(DISTINCT tmdb_id)
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'title + year',
    COUNT(*),
    COUNT(DISTINCT CONCAT(title, '|', year)),
    COUNT(*) - COUNT(DISTINCT CONCAT(title, '|', year))
FROM dbo.marvel_master_raw;

----------------------------------------------------------------

SELECT
    'tmdb_id + actor_tmdb_id' AS Key_Type,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(tmdb_id, '|', actor_tmdb_id)) AS Distinct_Values,
    COUNT(*) - COUNT(DISTINCT CONCAT(tmdb_id, '|', actor_tmdb_id)) AS Duplicate_Count
FROM dbo.marvel_cast_raw

UNION ALL

SELECT
    'tmdb_id + cast_order',
    COUNT(*),
    COUNT(DISTINCT CONCAT(tmdb_id, '|', cast_order)),
    COUNT(*) - COUNT(DISTINCT CONCAT(tmdb_id, '|', cast_order))
FROM dbo.marvel_cast_raw

UNION ALL

SELECT
    'tmdb_id + actor_tmdb_id + character',
    COUNT(*),
    COUNT(DISTINCT CONCAT(tmdb_id, '|', actor_tmdb_id, '|', character)),
    COUNT(*) - COUNT(DISTINCT CONCAT(tmdb_id, '|', actor_tmdb_id, '|', character))
FROM dbo.marvel_cast_raw

UNION ALL

SELECT
    'title + year + actor_name + character',
    COUNT(*),
    COUNT(DISTINCT CONCAT(title, '|', year, '|', actor_name, '|', character)),
    COUNT(*) - COUNT(DISTINCT CONCAT(title, '|', year, '|', actor_name, '|', character))
FROM dbo.marvel_cast_raw;

----------------------------------------------------------------------------------------

SELECT
    'title + year + source' AS Key_Type,
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(title, '|', year, '|', source)) AS Distinct_Values,
    COUNT(*) - COUNT(DISTINCT CONCAT(title, '|', year, '|', source)) AS Duplicate_Count
FROM dbo.marvel_ratings_raw;

----------------------------------------------------------

SELECT
    'marvel_master_raw' AS Table_Name,
    SUM(CASE WHEN id IS NULL OR LTRIM(RTRIM(id)) = '' THEN 1 ELSE 0 END) AS id_missing,
    SUM(CASE WHEN imdb_id IS NULL OR LTRIM(RTRIM(imdb_id)) = '' THEN 1 ELSE 0 END) AS imdb_id_missing,
    SUM(CASE WHEN tmdb_id IS NULL OR LTRIM(RTRIM(tmdb_id)) = '' THEN 1 ELSE 0 END) AS tmdb_id_missing
FROM dbo.marvel_master_raw

UNION ALL

SELECT
    'marvel_cast_raw',
    SUM(CASE WHEN tmdb_id IS NULL OR LTRIM(RTRIM(tmdb_id)) = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN actor_tmdb_id IS NULL OR LTRIM(RTRIM(actor_tmdb_id)) = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN cast_order IS NULL OR LTRIM(RTRIM(cast_order)) = '' THEN 1 ELSE 0 END)
FROM dbo.marvel_cast_raw

UNION ALL

SELECT
    'marvel_ratings_raw',
    SUM(CASE WHEN title IS NULL OR LTRIM(RTRIM(title)) = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN year IS NULL OR LTRIM(RTRIM(year)) = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN source IS NULL OR LTRIM(RTRIM(source)) = '' THEN 1 ELSE 0 END)
FROM dbo.marvel_ratings_raw;

-- Investigation 1 — Master IMDb/TMDB IDs --

-- We need to determine whether the non-null IDs themselves have duplicates. -- 

SELECT
    imdb_id,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE imdb_id IS NOT NULL
  AND LTRIM(RTRIM(imdb_id)) <> ''
GROUP BY imdb_id
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

SELECT
    tmdb_id,
    COUNT(*) AS Record_Count
FROM dbo.marvel_master_raw
WHERE tmdb_id IS NOT NULL
  AND LTRIM(RTRIM(tmdb_id)) <> ''
GROUP BY tmdb_id
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

SELECT *
FROM dbo.marvel_master_raw
WHERE LTRIM(RTRIM(tmdb_id)) IN ('225914.0', '225925.0')
ORDER BY tmdb_id, title;

-- Investigation 2 — Cast Table -- 

SELECT
    tmdb_id,
    actor_tmdb_id,
    actor_name,
    character,
    title,
    year,
    cast_order,
    COUNT(*) AS Record_Count
FROM dbo.marvel_cast_raw
GROUP BY
    tmdb_id,
    actor_tmdb_id,
    actor_name,
    character,
    title,
    year,
    cast_order
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-----

SELECT
    'tmdb_id + actor_tmdb_id' AS Key_Type,
    COUNT(*) AS Duplicate_Groups
FROM (
    SELECT
        tmdb_id,
        actor_tmdb_id
    FROM dbo.marvel_cast_raw
    WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(actor_tmdb_id)), '') IS NOT NULL
    GROUP BY
        tmdb_id,
        actor_tmdb_id
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'tmdb_id + cast_order',
    COUNT(*)
FROM (
    SELECT
        tmdb_id,
        cast_order
    FROM dbo.marvel_cast_raw
    WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(cast_order)), '') IS NOT NULL
    GROUP BY
        tmdb_id,
        cast_order
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'tmdb_id + actor_tmdb_id + character',
    COUNT(*)
FROM (
    SELECT
        tmdb_id,
        actor_tmdb_id,
        character
    FROM dbo.marvel_cast_raw
    WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(actor_tmdb_id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(character)), '') IS NOT NULL
    GROUP BY
        tmdb_id,
        actor_tmdb_id,
        character
    HAVING COUNT(*) > 1
) AS D

UNION ALL

SELECT
    'title + year + actor_name + character',
    COUNT(*)
FROM (
    SELECT
        title,
        year,
        actor_name,
        character
    FROM dbo.marvel_cast_raw
    WHERE NULLIF(LTRIM(RTRIM(title)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(year)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(actor_name)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(character)), '') IS NOT NULL
    GROUP BY
        title,
        year,
        actor_name,
        character
    HAVING COUNT(*) > 1
) AS D;

-- identify the records causing the three candidate-key collisions. --

-- Query 1 — tmdb_id + actor_tmdb_id -- 

SELECT
    tmdb_id,
    actor_tmdb_id,
    COUNT(*) AS Record_Count
FROM dbo.marvel_cast_raw
WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(actor_tmdb_id)), '') IS NOT NULL
GROUP BY
    tmdb_id,
    actor_tmdb_id
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-- Query 2 — tmdb_id + cast_order --

SELECT
    tmdb_id,
    cast_order,
    COUNT(*) AS Record_Count
FROM dbo.marvel_cast_raw
WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(cast_order)), '') IS NOT NULL
GROUP BY
    tmdb_id,
    cast_order
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-- Query 3 — tmdb_id + actor_tmdb_id + character --

SELECT
    tmdb_id,
    actor_tmdb_id,
    actor_name,
    character,
    COUNT(*) AS Record_Count
FROM dbo.marvel_cast_raw
WHERE NULLIF(LTRIM(RTRIM(tmdb_id)), '') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(actor_tmdb_id)), '') IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(character)), '') IS NOT NULL
GROUP BY
    tmdb_id,
    actor_tmdb_id,
    actor_name,
    character
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

--- Audit Conclusion ---
-- No duplicate cast records were identified. The apparent duplicate groups across TMDB-based candidate keys are attributable to --
-- two non-unique TMDB identifiers (225914.0 and 225925.0) that correspond to multiple distinct titles in the master dataset. 
-- The cast records remain unique when evaluated using the movie title, year, actor, and character combination. ----
