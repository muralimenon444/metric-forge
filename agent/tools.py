"""metric-forge agent tools. Read-only by design.

Run in a Databricks notebook (spark is provided) or import from the repo.
Each tool returns a short string, never raw unbounded data.
"""

import re

ALLOWED_PREFIXES = ("select", "with")
MAX_ROWS = 50


def run_readonly_sql(spark, query: str) -> str:
    """Run a single SELECT/WITH statement against the metric_forge schema."""
    q = query.strip().rstrip(";")
    if not q.lower().startswith(ALLOWED_PREFIXES) or ";" in q:
        return "Rejected: one read-only SELECT statement is allowed."
    rows = spark.sql(q).limit(MAX_ROWS).toPandas()
    return rows.to_json(orient="records")


def list_metric_views(spark, schema: str = "workspace.metric_forge") -> str:
    """List metric views in a schema. Metric views are views with WITH METRICS."""
    tables = spark.sql(f"SHOW TABLES IN {schema}").toPandas()
    names = tables["tableName"].tolist()
    return ", ".join(names) if names else "No objects found."


def metric_query(spark, view: str, measure: str, dimension: str | None = None) -> str:
    """Query a metric view with MEASURE(). Names are validated before use."""
    if not re.fullmatch(r"[\w.]+", view):
        return "Rejected: invalid view name."
    group = f"GROUP BY `{dimension}`" if dimension else ""
    select_dim = f"`{dimension}`, " if dimension else ""
    sql = f"SELECT {select_dim}MEASURE(`{measure}`) AS value FROM {view} {group}"
    return spark.sql(sql).limit(MAX_ROWS).toPandas().to_json(orient="records")


# Tool schemas for the model (OpenAI-compatible function calling).
TOOL_SCHEMAS = [
    {"type": "function", "function": {
        "name": "run_readonly_sql",
        "description": "Run one read-only SELECT against workspace.metric_forge. Prefer aggregates.",
        "parameters": {"type": "object",
                       "properties": {"query": {"type": "string"}},
                       "required": ["query"]}}},
    {"type": "function", "function": {
        "name": "list_metric_views",
        "description": "List objects in the metric_forge schema.",
        "parameters": {"type": "object", "properties": {}}}},
    {"type": "function", "function": {
        "name": "metric_query",
        "description": "Query a metric view by measure, optionally grouped by one dimension.",
        "parameters": {"type": "object",
                       "properties": {
                           "view": {"type": "string"},
                           "measure": {"type": "string"},
                           "dimension": {"type": "string"}},
                       "required": ["view", "measure"]}}},
]
