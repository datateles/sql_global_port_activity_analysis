
# Global Port Activity: EDA & Outlier Detection  
🛳️ *Analyzing global port activity using exploratory data analysis techniques.*

## **Table of Contents**

1. [Project Overview](#project-overview)  
2. [Dataset Description](#dataset-description)  
3. [Analysis Steps](#analysis-steps)  
4. [T-SQL Code](#t-sql-code)  
   - [4.1 Table Structure & Data Preview](#41-table-structure--data-preview)  
   - [4.2 Data Quality & Descriptives](#42-data-quality--descriptives)  
   - [4.3 Time Series Analysis](#43-time-series-analysis)  
   - [4.4 Anomaly & Outlier Detection](#44-anomaly--outlier-detection)  
   - [4.5 Country-Specific Analysis](#45-country-specific-analysis)  
   - [4.6 Year-over-Year Growth](#46-year-over-year-growth)  
   - [4.7 Top N Outliers per Country](#47-top-n-outliers-per-country)  
5. [Key Findings](#key-findings)

---

## **1. Project Overview**
This project focuses on analyzing global maritime trade and port activity using descriptive analytics and anomaly detection. The dataset contains vessel traffic, import/export volumes, and cargo types for hundreds of ports worldwide over multiple years.  
The goal is to understand trade flows, country and port performance, major trends, and outlier events in global shipping.

---

## **2. Dataset Description**
The dataset consists of **over 5 million records** across **30 columns**, covering **more than 100 countries and 400 ports** from **2019 to 2024**.

| Feature                  | Description                                                              |
|--------------------------|--------------------------------------------------------------------------|
| **date**                 | Date and time of record (UTC)                                            |
| **year**                 | Year of observation                                                      |
| **month**                | Month of observation (1–12)                                              |
| **day**                  | Day of the month (1–31)                                                  |
| **portid**               | Unique identifier for the port                                           |
| **portname**             | Name of the port                                                         |
| **country**              | Country where the port is located                                        |
| **ISO3**                 | ISO 3166-1 alpha-3 country code                                         |
| **portcalls_container**  | Number of port calls by container ships                                  |
| **portcalls_dry_bulk**   | Number of port calls by dry bulk ships                                   |
| **portcalls_general_cargo** | Number of port calls by general cargo ships                          |
| **portcalls_roro**       | Number of port calls by roll-on/roll-off (Ro-Ro) ships                   |
| **portcalls_tanker**     | Number of port calls by tanker ships                                     |
| **portcalls**            | Total number of port calls (all ship types)                              |
| **import_container**     | Imported cargo by container ships (metric tonnes)                        |
| **import_dry_bulk**      | Imported cargo by dry bulk ships (metric tonnes)                         |
| **import_general_cargo** | Imported cargo by general cargo ships (metric tonnes)                    |
| **import_roro**          | Imported cargo by ro-ro ships (metric tonnes)                            |
| **import_tanker**        | Imported cargo by tankers (metric tonnes)                                |
| **import_cargo**         | Total imported cargo (all ship types, metric tonnes)                     |
| **import**               | Total imported cargo (metric tonnes; often equal to import_cargo)        |
| **export_container**     | Exported cargo by container ships (metric tonnes)                        |
| **export_dry_bulk**      | Exported cargo by dry bulk ships (metric tonnes)                         |
| **export_general_cargo** | Exported cargo by general cargo ships (metric tonnes)                    |
| **export_roro**          | Exported cargo by ro-ro ships (metric tonnes)                            |
| **export_tanker**        | Exported cargo by tankers (metric tonnes)                                |
| **export_cargo**         | Total exported cargo (all ship types, metric tonnes)                     |
| **export**               | Total exported cargo (metric tonnes; often equal to export_cargo)        |
| **ObjectId**             | Unique row identifier                                                    |

---

## **3. Analysis Steps**

Data was analyzed using **T-SQL queries** in SQL Server.

✅ **Step 1: Data Collection & Inspection**  
➡ Load the dataset into SQL Server and perform an initial inspection to understand its structure, data types, and identify any missing values or anomalies.

✅ **Step 2: Descriptive Statistics**  
➡ Calculate basic descriptive statistics such as minimum, maximum, mean, and standard deviation to summarize numeric variables.

✅ **Step 3: Trend Analysis**  
➡ Summarize and visualize trends over time (monthly, daily, and yearly) for import/export data and port activity.

✅ **Step 4: Anomaly & Outlier Detection**  
➡ Detect anomalous and outlier values in import and export data both globally and by country using statistical techniques.

✅ **Step 5: Country & Cargo Type Analysis**  
➡ Aggregate and compare port activity and cargo movement by country and cargo type to identify key contributors and trends.

✅ **Step 6: Year-over-Year Growth Calculation**  
➡ Calculate and compare year-over-year growth for import and export totals overall and by country.

✅ **Step 7: Top Outliers Ranking**  
➡ Rank the top N outlier events per country and year for focused investigation.

---

## **4. T-SQL Code**

### 4.1 Table Structure & Data Preview

```sql
-- View columns and types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'global_port_activity';

-- Preview first 10 rows
SELECT TOP 10 * FROM global_port_activity;
```


### 4.2 Data Quality & Descriptives

```sql
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
```

---

### 4.3 Time Series Analysis

```sql
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
```

---

### 4.4 Anomaly & Outlier Detection

```sql
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
```

---

### 4.5 Country-Specific Analysis

```sql
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
```

**Country-specific outliers:**

```sql
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
```

---

### 4.6 Year-over-Year Growth

```sql
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
```

---

### 4.7 Top N Outliers per Country

```sql
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
```

---


## **5. Key Findings**

- **Dataset period:** January 1, 2024 to October 27, 2024 (latest available data).
- **Countries represented:** 113  
- **Ports represented:** 487

- **Global totals:**
  - **Total imports:** 1,694,091,881 metric tonnes (≈1.69 billion tonnes)
  - **Total exports:** 1,528,846,404 metric tonnes (≈1.53 billion tonnes)

- **Top 5 countries by total exports in 2024:**
  1. **China:** 362.7 million tonnes
  2. **Brazil:** 123.9 million tonnes
  3. **Russian Federation:** 102.6 million tonnes
  4. **Singapore:** 91.9 million tonnes
  5. **United States:** 88.3 million tonnes

- **Top 5 ports by export volume:**
  1. **Shanghai**
  2. **Singapore**
  3. **Santos**
  4. **Ust-Luga**
  5. **Qingdao**

- **Major outliers in export volume (z-score > 3):**
  - The largest export outlier is **Bandar-E Pars Terminal (Iran)** on 2024-08-28, with 1.39 million tonnes (z-score ≈ 40).
  - Several extremely high export values observed in **Shanghai (China)**, with multiple dates exceeding z-score 27.

- **No missing values** detected in any column; data quality is high.

- **Dry bulk shipping dominates** the largest export events for 2024.
