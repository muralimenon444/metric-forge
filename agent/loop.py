"""metric-forge agent loop: a model that can call read-only tools, with budgets.

Run in a Databricks notebook (spark is provided) after importing tools.py.
Replace MODEL with a chat endpoint that exists in your workspace (Serving page).
"""

import json

from databricks_openai import DatabricksOpenAI

from tools import TOOL_SCHEMAS, list_metric_views, metric_query, run_readonly_sql

MODEL = "databricks-meta-llama-3-3-70b-instruct"  # replace with your endpoint name
MAX_STEPS = 5  # budget: the most model turns one question may take

SYSTEM = """You are a data engineering assistant for the metric-forge analytics layer.
- Use tools before answering. Base every number on a tool result.
- Prefer metric_query for business metrics, so definitions stay consistent.
- Use run_readonly_sql only for checks metric views cannot answer.
- If a tool rejects a request or returns nothing, say so. Do not guess.
"""

client = DatabricksOpenAI()


def dispatch(spark, name: str, args: dict) -> str:
    """Route a model tool call to the matching Python function."""
    if name == "run_readonly_sql":
        return run_readonly_sql(spark, args["query"])
    if name == "list_metric_views":
        return list_metric_views(spark)
    if name == "metric_query":
        return metric_query(spark, args["view"], args["measure"], args.get("dimension"))
    return f"Unknown tool: {name}"


def answer(spark, question: str) -> str:
    messages = [
        {"role": "system", "content": SYSTEM},
        {"role": "user", "content": question},
    ]
    for step in range(MAX_STEPS):
        resp = client.chat.completions.create(model=MODEL, messages=messages, tools=TOOL_SCHEMAS)
        msg = resp.choices[0].message
        messages.append(msg)

        if not msg.tool_calls:  # the model answered without needing a tool
            return msg.content

        for call in msg.tool_calls:
            args = json.loads(call.function.arguments)
            result = dispatch(spark, call.function.name, args)
            messages.append({"role": "tool", "tool_call_id": call.id, "content": result})

    return f"Stopped after {MAX_STEPS} steps without a final answer."


# Try it in the notebook:
# print(answer(spark, "What is the average length of stay by department?"))
