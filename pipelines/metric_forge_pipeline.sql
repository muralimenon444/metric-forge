-- metric-forge Lakeflow Declarative Pipeline (SQL)
-- Create the pipeline in Jobs & Pipelines with:
--   Default catalog: workspace    Default schema: metric_forge    Language: SQL
-- Source feeds are written by notebooks/02_generate_synthetic_data.py.

-- BRONZE: raw landing, one streaming table per feed
CREATE OR REFRESH STREAMING TABLE pl_bronze_patients AS
SELECT * FROM STREAM read_files('/Volumes/workspace/metric_forge/raw/patients/',
  format => 'csv', header => true);

CREATE OR REFRESH STREAMING TABLE pl_bronze_encounters AS
SELECT * FROM STREAM read_files('/Volumes/workspace/metric_forge/raw/encounters/',
  format => 'csv', header => true);

CREATE OR REFRESH STREAMING TABLE pl_bronze_lab_results AS
SELECT * FROM STREAM read_files('/Volumes/workspace/metric_forge/raw/lab_results/',
  format => 'csv', header => true);

-- SILVER: typed, deduplicated, validated
CREATE OR REFRESH MATERIALIZED VIEW pl_silver_patients (
  CONSTRAINT valid_mrn EXPECT (mrn RLIKE '^MRN[0-9]{6}$') ON VIOLATION DROP ROW
) AS
SELECT DISTINCT pat_id, mrn, sex, CAST(birth_year AS INT) AS birth_year, zip3
FROM pl_bronze_patients;

CREATE OR REFRESH MATERIALIZED VIEW pl_silver_encounters (
  CONSTRAINT has_csn EXPECT (csn IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_times EXPECT (discharge_ts >= admit_ts) ON VIOLATION DROP ROW,
  CONSTRAINT has_attending EXPECT (attending_prov_id IS NOT NULL)
) AS
SELECT CAST(csn AS BIGINT) AS csn, pat_id, dept_code, enc_type,
       CAST(admit_ts AS TIMESTAMP) AS admit_ts,
       CAST(discharge_ts AS TIMESTAMP) AS discharge_ts,
       attending_prov_id
FROM pl_bronze_encounters;

CREATE OR REFRESH MATERIALIZED VIEW pl_silver_lab_results (
  CONSTRAINT has_result EXPECT (result_value IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT creatinine_unit EXPECT (NOT (test_code = '2160-0' AND unit <> 'mg/dL'))
    ON VIOLATION DROP ROW
) AS
SELECT CAST(result_id AS BIGINT) AS result_id, CAST(csn AS BIGINT) AS csn,
       test_code, test_name,
       CAST(result_value AS DOUBLE) AS result_value, unit,
       CAST(ref_low AS DOUBLE) AS ref_low, CAST(ref_high AS DOUBLE) AS ref_high,
       CAST(result_ts AS TIMESTAMP) AS result_ts
FROM pl_bronze_lab_results;

-- GOLD: business aggregates
CREATE OR REFRESH MATERIALIZED VIEW gold_ed_volume_daily AS
SELECT CAST(admit_ts AS DATE) AS admit_date, count(*) AS ed_encounters
FROM pl_silver_encounters
WHERE dept_code = 'ED'
GROUP BY CAST(admit_ts AS DATE);

CREATE OR REFRESH MATERIALIZED VIEW gold_abnormal_labs AS
SELECT test_name,
       count(*) AS total_results,
       sum(CASE WHEN result_value < ref_low OR result_value > ref_high THEN 1 ELSE 0 END)
         AS abnormal_results
FROM pl_silver_lab_results
GROUP BY test_name;
