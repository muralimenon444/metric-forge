-- Module 01: Unity Catalog basics
-- Concept and steps: docs/modules/01-unity-catalog.md
-- Run section by section in the Databricks SQL editor or a notebook with serverless compute.
-- Every statement here is safe to re-run.

-- 1. Create the project schema (the container for every later object)
CREATE SCHEMA IF NOT EXISTS workspace.metric_forge
  COMMENT 'metric-forge learning project: raw sources, bronze, silver, gold, metric views.';

-- 2. Create the raw landing volume for source files
CREATE VOLUME IF NOT EXISTS workspace.metric_forge.raw
  COMMENT 'Landing zone for synthetic source files (fictional data).';

-- 3. Explore the three-level namespace
SHOW SCHEMAS IN workspace;
SHOW VOLUMES IN workspace.metric_forge;
DESCRIBE SCHEMA EXTENDED workspace.metric_forge;

-- 4. Create a small managed table to see where Unity Catalog stores its data
CREATE TABLE IF NOT EXISTS workspace.metric_forge.uc_demo (
  id   INT,
  note STRING
);

INSERT INTO workspace.metric_forge.uc_demo VALUES (1, 'hello unity catalog');

SELECT * FROM workspace.metric_forge.uc_demo;

-- Check the table type (MANAGED) and the storage location
DESCRIBE DETAIL workspace.metric_forge.uc_demo;
DESCRIBE TABLE EXTENDED workspace.metric_forge.uc_demo;

-- 5. Inspect privileges on the schema and volume
--    On a personal workspace you'll mostly see your own ownership.
SHOW GRANTS ON SCHEMA workspace.metric_forge;
SHOW GRANTS ON VOLUME workspace.metric_forge.raw;

-- 6. Optional exercise: grant read access to a group, then revoke it.
--    Replace `analysts` with a group that exists in your workspace.
--    GRANT USE SCHEMA, SELECT ON SCHEMA workspace.metric_forge TO `analysts`;
--    REVOKE USE SCHEMA, SELECT ON SCHEMA workspace.metric_forge FROM `analysts`;

-- 7. Cleanup for this module only. Keep the schema and the raw volume.
-- DROP TABLE IF EXISTS workspace.metric_forge.uc_demo;
