USE Marvel_SQL_Analysis;
GO

TRUNCATE TABLE dbo.marvel_master_raw;
GO

SELECT COUNT(*) AS row_count
FROM dbo.marvel_master_raw;

USE Marvel_SQL_Analysis;
GO

SELECT COUNT(*) AS total_rows
FROM dbo.marvel_master_raw;

SELECT TOP 10 *
FROM dbo.marvel_master_raw;

SELECT 
    COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'marvel_master_raw';

USE Marvel_SQL_Analysis;
GO

DROP TABLE IF EXISTS dbo.marvel_cast_raw;
GO

CREATE TABLE dbo.marvel_cast_raw
(
    title           NVARCHAR(MAX),
    year            NVARCHAR(MAX),
    tmdb_id         NVARCHAR(MAX),
    actor_name      NVARCHAR(MAX),
    character       NVARCHAR(MAX),
    cast_order      NVARCHAR(MAX),
    actor_tmdb_id   NVARCHAR(MAX),
    popularity      NVARCHAR(MAX),
    profile_path    NVARCHAR(MAX)
);
GO

SELECT COUNT(*) AS total_rows
FROM dbo.marvel_cast_raw;

USE Marvel_SQL_Analysis;
GO

DROP TABLE IF EXISTS dbo.marvel_ratings_raw;
GO

CREATE TABLE dbo.marvel_ratings_raw
(
    title   NVARCHAR(MAX),
    year    NVARCHAR(MAX),
    source  NVARCHAR(MAX),
    score   NVARCHAR(MAX)
);
GO

EXEC sp_help 'dbo.marvel_ratings_raw';

SELECT COUNT(*) AS total_rows
FROM dbo.marvel_ratings_raw;

SELECT 'marvel_master_raw' AS table_name,
       COUNT(*) AS row_count
FROM dbo.marvel_master_raw

UNION ALL

SELECT 'marvel_cast_raw',
       COUNT(*)
FROM dbo.marvel_cast_raw

UNION ALL

SELECT 'marvel_ratings_raw',
       COUNT(*)
FROM dbo.marvel_ratings_raw;