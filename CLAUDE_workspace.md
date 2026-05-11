# iconic_trades — Agent Guidance

This workspace was scaffolded by the `vibedata-data-engineering` plugin.

## Plugin Rules

Agent rules and skill playbooks live in the loaded plugin (`vibedata-data-engineering`). When the agent starts work in this directory, those rules apply.

## Project Context

- **Project name:** iconic_trades
- **Data domain:** Iconic Trades
- **Destination:** DuckDB (`./data/only_trade.duckdb`)
- **Source system:** TBD

## Structure

```
iconic_trades/
├── models/           # dbt models (staging / intermediate / marts)
├── dlt/              # dlt pipeline files and source tree
├── tests/            # pytest unit and data tests
├── seeds/            # reference data CSVs
├── .env              # secrets — never commit
└── design.md         # intent progress tracker
```

## Startup

The agent loads `classifying-data-intents` on session start via the SessionStart hook. The classified intent drives which skills are invoked.
