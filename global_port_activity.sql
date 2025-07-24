
-- 4.1 Table Structure & Data Preview

-- View columns and types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'global_port_activity';

-- Preview first 10 rows
SELECT TOP 10 * FROM global_port_activity;

-- 4.2 Data Quality & Descriptives

-- Row and null counts (expand for more columns)
SELECT COUNT(*) AS total_rows FROM global_port_activity;

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN portname IS NULL THEN 1 ELSE 0 END) AS null_portname,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM global_port_activity;

-- Distinct values
SELECT DISTINCT country FROM global_port_activity;
SELECT DISTINCT portname FROM global_port_activity;

-- Descriptive statistics (example)
SELECT 
    MIN(import_cargo) AS min_import_cargo,
    MAX(import_cargo) AS max_import_cargo,
    AVG(import_cargo) AS avg_import_cargo,
    STDEV(import_cargo) AS std_import_cargo
FROM global_port_activity;

-- 4.3 Time Series Analysis

-- Monthly totals by year and month
SELECT 
    year, month, SUM(import) AS total_import, SUM(export) AS total_export
FROM global_port_activity
GROUP BY year, month
ORDER BY year, month;

-- Daily trends for a specific country (edit as needed)
SELECT 
    date, SUM(import) AS daily_import, SUM(export) AS daily_export
FROM global_port_activity
WHERE country = 'Australia'
GROUP BY date
ORDER BY date;

-- 4.4 Anomaly & Outlier Detection

-- Import outliers (global)
WITH stats AS (
    SELECT AVG(import) AS avg_import, STDEV(import) AS std_import
    FROM global_port_activity
)
SELECT date, portname, country, import, export
FROM global_port_activity, stats
WHERE ABS(import - stats.avg_import) > 2 * stats.std_import
ORDER BY ABS(import - stats.avg_import) DESC;

-- Export outliers (global)
WITH stats AS (
    SELECT AVG(export) AS avg_export, STDEV(export) AS std_export
    FROM global_port_activity
)
SELECT date, portname, country, import, export
FROM global_port_activity, stats
WHERE ABS(export - stats.avg_export) > 2 * stats.std_export
ORDER BY ABS(export - stats.avg_export) DESC;

-- Top 10 highest/lowest import days
SELECT TOP 10 date, portname, country, import
FROM global_port_activity
ORDER BY import DESC;

SELECT TOP 10 date, portname, country, import
FROM global_port_activity
WHERE import > 0
ORDER BY import ASC;

-- 4.5 Country-Specific Analysis

-- Total import/export per country
SELECT country, SUM(import) AS total_import, SUM(export) AS total_export
FROM global_port_activity
GROUP BY country
ORDER BY total_import DESC;

-- By country and year
SELECT country, year, SUM(import) AS yearly_import, SUM(export) AS yearly_export
FROM global_port_activity
GROUP BY country, year
ORDER BY country, year;

-- Cargo type breakdown by country
SELECT country,
    SUM(import_container) AS import_container,
    SUM(import_dry_bulk) AS import_dry_bulk,
    SUM(import_general_cargo) AS import_general_cargo,
    SUM(import_roro) AS import_roro,
    SUM(import_tanker) AS import_tanker,
    SUM(export_container) AS export_container,
    SUM(export_dry_bulk) AS export_dry_bulk,
    SUM(export_general_cargo) AS export_general_cargo,
    SUM(export_roro) AS export_roro,
    SUM(export_tanker) AS export_tanker
FROM global_port_activity
GROUP BY country
ORDER BY country;

-- Import outliers by country
WITH country_stats AS (
    SELECT country, AVG(import) AS avg_import, STDEV(import) AS std_import
    FROM global_port_activity
    GROUP BY country
)
SELECT gpa.date, gpa.portname, gpa.country, gpa.import,
       cs.avg_import, cs.std_import,
       (gpa.import - cs.avg_import) / NULLIF(cs.std_import, 0) AS import_zscore
FROM global_port_activity gpa
INNER JOIN country_stats cs ON gpa.country = cs.country
WHERE cs.std_import > 0
  AND ABS(gpa.import - cs.avg_import) > 2 * cs.std_import
ORDER BY gpa.country, ABS(gpa.import - cs.avg_import) DESC;

-- Export outliers by country
WITH country_stats AS (
    SELECT country, AVG(export) AS avg_export, STDEV(export) AS std_export
    FROM global_port_activity
    GROUP BY country
)
SELECT gpa.date, gpa.portname, gpa.country, gpa.export,
       cs.avg_export, cs.std_export,
       (gpa.export - cs.avg_export) / NULLIF(cs.std_export, 0) AS export_zscore
FROM global_port_activity gpa
INNER JOIN country_stats cs ON gpa.country = cs.country
WHERE cs.std_export > 0
  AND ABS(gpa.export - cs.avg_export) > 2 * cs.std_export
ORDER BY gpa.country, ABS(gpa.export - cs.avg_export) DESC;

-- 4.6 Year-over-Year Growth

-- YoY growth (total)
WITH yearly_totals AS (
    SELECT year, SUM(import) AS total_import, SUM(export) AS total_export
    FROM global_port_activity
    GROUP BY year
)
SELECT yt1.year, yt1.total_import, yt1.total_export,
       yt1.total_import - yt2.total_import AS import_growth,
       yt1.total_export - yt2.total_export AS export_growth,
       CASE WHEN yt2.total_import = 0 THEN NULL 
            ELSE (CAST(yt1.total_import AS FLOAT) - yt2.total_import) / yt2.total_import * 100 END AS import_growth_pct,
       CASE WHEN yt2.total_export = 0 THEN NULL 
            ELSE (CAST(yt1.total_export AS FLOAT) - yt2.total_export) / yt2.total_export * 100 END AS export_growth_pct
FROM yearly_totals yt1
LEFT JOIN yearly_totals yt2 ON yt1.year = yt2.year + 1
ORDER BY yt1.year;

-- YoY growth by country
WITH yearly_country_totals AS (
    SELECT country, year, SUM(import) AS total_import, SUM(export) AS total_export
    FROM global_port_activity
    GROUP BY country, year
)
SELECT yct1.country, yct1.year, yct1.total_import, yct1.total_export,
       yct1.total_import - yct2.total_import AS import_growth,
       yct1.total_export - yct2.total_export AS export_growth,
       CASE WHEN yct2.total_import = 0 THEN NULL
            ELSE (CAST(yct1.total_import AS FLOAT) - yct2.total_import) / yct2.total_import * 100 END AS import_growth_pct,
       CASE WHEN yct2.total_export = 0 THEN NULL
            ELSE (CAST(yct1.total_export AS FLOAT) - yct2.total_export) / yct2.total_export * 100 END AS export_growth_pct
FROM yearly_country_totals yct1
LEFT JOIN yearly_country_totals yct2
    ON yct1.country = yct2.country AND yct1.year = yct2.year + 1
ORDER BY yct1.country, yct1.year;

-- 4.7 Top N Outliers per Country

-- Top N Import Outliers per Country (example: top 3, 2021)
WITH country_stats AS (
    SELECT country, AVG(import) AS avg_import, STDEV(import) AS std_import
    FROM global_port_activity
    WHERE year = 2021
    GROUP BY country
),
outliers AS (
    SELECT gpa.date, gpa.portname, gpa.country, gpa.import,
           cs.avg_import, cs.std_import,
           (gpa.import - cs.avg_import) / NULLIF(cs.std_import, 0) AS import_zscore,
           ROW_NUMBER() OVER (
               PARTITION BY gpa.country 
               ORDER BY ABS((gpa.import - cs.avg_import) / NULLIF(cs.std_import, 0)) DESC
           ) AS rn
    FROM global_port_activity gpa
    INNER JOIN country_stats cs ON gpa.country = cs.country
    WHERE gpa.year = 2021 AND cs.std_import > 0
)
SELECT *
FROM outliers
WHERE rn <= 3
ORDER BY country, rn;

-- Top N Export Outliers per Country (example: top 3, 2021)
WITH country_stats AS (
    SELECT country, AVG(export) AS avg_export, STDEV(export) AS std_export
    FROM global_port_activity
    WHERE year = 2021
    GROUP BY country
),
outliers AS (
    SELECT gpa.date, gpa.portname, gpa.country, gpa.export,
           cs.avg_export, cs.std_export,
           (gpa.export - cs.avg_export) / NULLIF(cs.std_export, 0) AS export_zscore,
           ROW_NUMBER() OVER (
               PARTITION BY gpa.country 
               ORDER BY ABS((gpa.export - cs.avg_export) / NULLIF(cs.std_export, 0)) DESC
           ) AS rn
    FROM global_port_activity gpa
    INNER JOIN country_stats cs ON gpa.country = cs.country
    WHERE gpa.year = 2021 AND cs.std_export > 0
)
SELECT *
FROM outliers
WHERE rn <= 3
ORDER BY country, rn;
