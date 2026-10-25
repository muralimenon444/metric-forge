-- metric-forge: metric view over the silver encounters table
-- Requires the pipeline in pipelines/metric_forge_pipeline.sql to have run.
-- Syntax: CREATE VIEW ... WITH METRICS LANGUAGE YAML (Databricks docs: metric views).
-- Requires Databricks Runtime 17.3+ or serverless compute.

CREATE OR REPLACE VIEW workspace.metric_forge.encounter_metrics WITH METRICS LANGUAGE YAML AS
$$
  version: 1.1
  comment: "Encounter KPIs for operational analytics (synthetic data)"
  source: workspace.metric_forge.pl_silver_encounters

  fields:
    - name: Admit Date
      expr: CAST(source.admit_ts AS DATE)
      comment: "Date of admission"

    - name: Department
      expr: source.dept_code
      comment: "Department code"

    - name: Encounter Type
      expr: source.enc_type
      comment: "Encounter type"

  measures:
    - name: Encounter Count
      expr: COUNT(1)
      comment: "Number of valid encounters"

    - name: Avg Length of Stay Hours
      expr: AVG((unix_timestamp(source.discharge_ts) - unix_timestamp(source.admit_ts)) / 3600.0)
      comment: "Average hours from admit to discharge"
$$;

-- Query it with MEASURE() to get the metric consistently:
SELECT `Department`, MEASURE(`Encounter Count`) AS encounters,
       MEASURE(`Avg Length of Stay Hours`) AS avg_los_hours
FROM workspace.metric_forge.encounter_metrics
GROUP BY `Department`;
