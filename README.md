# metric-forge

An agentic assistant for the analytics layer on Databricks: validates metric views, checks bronze/silver/gold consistency, and detects pipeline drift. Built with synthetic healthcare data.

This is a hands-on learning project. It's built module by module so each Databricks building block is explained, practiced, and checked before the agent depends on it. It's not a production system.

## Data disclaimer

All data in this repository is **synthetic and fictional**. Patients, encounters, and lab results are invented. The tables are modeled loosely on how EHR (Epic-style) data is organized, but they are not extracts from any real system. Epic is a trademark of Epic Systems; this project is not affiliated with or endorsed by Epic.

Do not load real patient data (PHI) into this project.

## Roadmap

The agent's jobs are built in phases, each ending in an evaluated feature.

| Phase | Agent job | Status |
|---|---|---|
| 1 | Metric consistency checks: compare metric view definitions against the gold tables they reflect | Planned |
| 2 | Metric view authoring and validation: draft from a spec, validate, propose for review | Planned |
| 3 | Drift detection: flag upstream schema changes that would break silver or gold objects | Planned |
| 4 | Medallion generation: produce bronze, silver, and gold SQL from a spec | Planned |

## Learning modules

Work through these in order. Each module has a concept explanation, a hands-on step, and a checkpoint.

| # | Module | Status |
|---|---|---|
| 01 | [Unity Catalog basics](docs/modules/01-unity-catalog.md) | In progress |
| 02 | Medallion architecture (bronze, silver, gold) | Planned |
| 03 | Lakeflow pipelines and data quality expectations | Planned |
| 04 | Metric views | Planned |
| 05 | Lineage and system tables | Planned |
| 06 | Agent tools | Planned |
| 07 | Agent loop and guardrails | Planned |
| 08 | Evaluation | Planned |

## Repository layout

```
metric-forge/
├── docs/modules/   # Learning modules: concepts, steps, checkpoints
├── sql/            # Unity Catalog setup, medallion SQL, metric view definitions
├── pipelines/      # Lakeflow pipeline definitions
├── data/synthetic/ # Synthetic source files (fictional)
├── agent/          # Tool functions and the agent loop
├── evals/          # Golden question sets and scoring
└── notebooks/      # Setup and exploration notebooks
```

## Environment

- Databricks workspace (Free Edition works for most modules)
- Serverless compute
- Unity Catalog enabled

Features such as system tables, Model Serving options, and metric views may vary by workspace. Check feature availability in your workspace before assuming a step is wrong.

## License

MIT. See [LICENSE](LICENSE).
