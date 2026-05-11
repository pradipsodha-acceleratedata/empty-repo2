# Intent: Bank Failures Data Mart

## Goal

Create a bank failures data mart to support analysis of bank failure events, enabling business users to track failure trends, understand failure patterns, and analyze financial impact. The mart will transform upstream source data into a queryable analytical model following the Iconic Trades medallion architecture.

## Source System

**Open question:** What is the upstream source for bank failures data? 
- Is this coming from staging models (e.g., `stg_*__bank_failures`)?
- Is there raw/bronze data already loaded?
- Is this derived from existing models in the project?
- What system originally provides bank failure data (e.g., FDIC data, internal tracking system)?

## Target

- **Database:** DuckDB
- **Location (dev):** `./data/only_trade.duckdb`
- **Location (prod):** `/home/pdip/Downloads/only_trade.duckdb`
- **Schema:** `main`
- **Materialization:** Table (following mart conventions)

## Objects in Scope

**Open question:** What specific models/tables should be created?
- Likely `fct_bank_failures` (fact table tracking failure events)?
- Are dimension tables needed (e.g., `dim_bank`, `dim_failure_type`)?
- What grain should the fact table have (one row per bank failure event, or aggregated by time period)?

## Success Criteria

- [ ] Mart model(s) created following naming convention (`fct_*` or `dim_*`)
- [ ] Model successfully builds and materializes as table in DuckDB
- [ ] Required tests passing:
  - `not_null` on all primary keys
  - `unique` on all primary keys
  - `relationships` on all foreign keys (if applicable)
- [ ] Model documented with grain statement and column descriptions
- [ ] Data validated within tolerance thresholds (±2% row count acceptable)

**Open question:** Are there specific business metrics or KPIs this mart must support?

## Out of Scope

- Ingestion of raw bank failure data from external sources (assumes upstream data already exists)
- Real-time or streaming updates (batch processing only)
- Historical backfill beyond what exists in source data

## Open Questions

1. **Source identification:** What upstream models or tables contain the bank failure data to be transformed?
2. **Mart structure:** Should this be a single fact table (`fct_bank_failures`) or multiple models (fact + dimensions)?
3. **Grain:** What is the grain of the fact table? (e.g., one row per bank failure event, one row per bank per month)
4. **Dimensions:** What attributes need to be tracked? (e.g., bank name, failure date, location, assets, deposit insurance coverage, acquiring institution)
5. **Metrics:** What measures should be calculated? (e.g., total assets, total deposits, number of failures by period)
6. **Time period:** What date range should be covered?
7. **Business rules:** Are there specific filters or transformations required? (e.g., exclude certain failure types, adjust for inflation)
