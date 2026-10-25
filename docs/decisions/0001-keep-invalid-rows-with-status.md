# 0001: Keep invalid rows with a status instead of dropping them

**Status:** Accepted (planned change, not yet implemented)

## Context
The first pipeline used `ON VIOLATION DROP ROW` to remove bad records from silver. Dropped rows were visible only in the pipeline event log, so metrics and reports looked complete when they weren't.

## Decision
- Keep every record in silver with a `status` (`valid` or `excluded`) and a `exclusion_reason`.
- Metrics count only `valid` rows by default.
- Metric views expose excluded counts and reasons alongside each metric.
- The agent must state excluded counts with every answer.
- Duplicate records are flagged as `excluded: duplicate_record`, not removed silently.
- Each layer reconciles: received = valid + excluded. A mismatch fails the run.

## Consequences
- Silver contains bad rows. Anyone querying silver directly must filter on `status`.
- Pipeline and metric definitions get more complex.
- Exclusion rates per rule become a monitored signal.

## Rejected alternative
Dropping rows, or moving them to a separate quarantine table. Both hide the gap from people reading the metrics.
