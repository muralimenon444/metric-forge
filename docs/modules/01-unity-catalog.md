# Module 01: Unity Catalog basics

**Time:** about 30 minutes
**Builds:** the `workspace.metric_forge` schema and the `raw` volume that every later module uses.
**Code:** [`sql/01_unity_catalog.sql`](../../sql/01_unity_catalog.sql)

## Why this comes first

Every object in the metric-forge project lives in Unity Catalog: source files, bronze/silver/gold tables, metric views, and the tools the agent calls. Lineage, permissions, and audit logs all come from Unity Catalog. If you understand how it organizes objects, the rest of the project makes sense.

## Concepts

### The three-level namespace

Every object has a full name made of three parts:

```
catalog . schema . object
workspace . metric_forge . silver_encounters
```

- **Catalog:** the top-level container. In Free Edition it's usually `workspace`. In a company it might be `prod_analytics` or `healthcare_dev`.
- **Schema** (also called a database): groups related objects. This project uses one schema, `metric_forge`.
- **Object:** a table, view, volume, function, or metric view.

Always use the full three-part name in code. It avoids ambiguity about which catalog a query is reading from, which matters when the agent writes SQL.

### Metastore

The **metastore** is the account-level container that holds catalogs and manages permissions across workspaces. You usually don't create one yourself. In your workspace it's already set up, and the catalogs you see sit inside it.

### Managed vs. external tables

- **Managed tables:** Unity Catalog decides where the data is stored and manages its lifecycle. Dropping the table deletes the data. This is the default, and what you'll use.
- **External tables:** you point the table at a storage location you control. Dropping the table removes only the metadata.

Most learning projects use managed tables. Module 01 has you check where a managed table's data actually lives.

### Volumes

Tables hold structured data. **Volumes** hold files: CSVs, JSON, Parquet, PDFs, and anything else that isn't a table yet. Volumes are governed the same way as tables, and you can read them with a path:

```
/Volumes/workspace/metric_forge/raw/encounters.csv
```

In this project, `raw` is the landing zone for synthetic source files. The Lakeflow pipelines in later modules read from it.

### Privileges and grants

Access is controlled with `GRANT` and `REVOKE` on catalogs, schemas, tables, volumes, and functions. Common privileges:

- `USE CATALOG` and `USE SCHEMA`: needed to see anything inside
- `SELECT`: read a table or view
- `MODIFY`: write to a table
- `CREATE TABLE`, `CREATE VOLUME`: create objects in a schema

For this project's agent, the principle is **least privilege**: the agent's identity should only be able to read the objects it needs, and only write where a later module explicitly allows it.

### Why it matters for the agent

The agent's tools are Unity Catalog objects, and the agent runs under an identity with specific grants. A tool can't return data the identity can't read, no matter what the prompt says. This is why governance is a design decision and not a cleanup step.

## Hands-on steps

1. In your Databricks workspace, open the **SQL Editor** or create a notebook attached to serverless compute.
2. Open [`sql/01_unity_catalog.sql`](../../sql/01_unity_catalog.sql) and run it, one section at a time.
3. In **Catalog Explorer**, find `workspace` → `metric_forge`. Confirm you see the `raw` volume and the `uc_demo` table.
4. Open `uc_demo` and go to the **Details** tab. Find the storage location and the table type (managed).
5. Upload a small test file to the `raw` volume through Catalog Explorer, then confirm you can list it with:

   ```sql
   LIST '/Volumes/workspace/metric_forge/raw/';
   ```

   Use this for any file. Module 02 will provide the real synthetic data.

## Checkpoint

You can answer these without looking at the docs:

1. What are the three parts of a full object name, and what does each one contain?
2. If you drop a managed table, what happens to its data?
3. What is the difference between a table and a volume?
4. Why should the agent run under its own identity instead of yours?

## Exercise

Create a second schema called `scratch` and a table in it. Then try to read the `scratch` table from a different catalog context using only its short name. Explain what happens and why the full name prevents this confusion.

Bring back: the output of `DESCRIBE DETAIL workspace.metric_forge.uc_demo` (paste it as text) and your answers to the checkpoint. If anything fails, paste the error text and the step number.

## Cleanup

The `uc_demo` table is for this module only. Drop it when you're done:

```sql
DROP TABLE IF EXISTS workspace.metric_forge.uc_demo;
```

Keep the schema and the `raw` volume. Later modules use them.
