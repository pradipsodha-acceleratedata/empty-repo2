# Design: Bank Failures Data Mart

## Progress

| Phase / Gate | Date | Notes |
|---|---|---|
| Phase 0 — Intent classification | 2026-05-11 | ✅ Classified as work/transformation |
| Phase 1 — Workspace | 2026-05-11 | ✅ dbt project scaffolded, dbt debug passed |
| Phase 2 — Requirements | 2026-05-11 | ✅ Source identified (src.bank_failures), mart structure confirmed |
| Phase 3a — Plan skeleton + change-impact | 2026-05-11 | In progress |
| Phase 3b — Specialized design (profile/discover) | | |
| Phase 3 — Design approval | | |
| Phase 4a — Generate (per artifact) | | |
| Phase 4b — Unit tests | | |
| Phase 4c — Data tests | | |
| Phase 4d — Validation (golden / fixture replay, if applicable) | | |
| Phase 4d.5 — Audit | | |
| Phase 4e — Contract authoring | | |
| Phase 4f — Code review | | |
| Phase 5a — Schema delta approval | | |
| Phase 5b — Documentation | | |
| Phase 5e — PR Workflow | | |

## Model Inventory

| Model Name | Type | Materialization | Source(s) | Grain | Status | Notes |
|---|---|---|---|---|---|---|
| stg_src__bank_failures | staging | view | src.bank_failures | One row per bank failure event | pending | 1:1 with source, rename columns, clean data types |
| fct_bank_failures | mart | table | stg_src__bank_failures | One row per bank failure event | pending | Final mart with business logic |

## Change Impact

No existing artifacts impacted — fresh build target.

## Artifacts

### Models
- `models/staging/stg_src__bank_failures.sql`
- `models/staging/stg_src__bank_failures.yml` (schema + tests)
- `models/marts/fct_bank_failures.sql`
- `models/marts/fct_bank_failures.yml` (schema + tests + contract)

### Sources
- `models/staging/sources.yml` (define src.bank_failures source)

## Requirements Summary

**Source:** `src.bank_failures` table in domain database
- 545 bank failures (2008-01-25 to 2024-10-18)
- Columns: c1, Bank, City, State, Date, Acquired by, Assets ($mil.)

**Target:** Single fact table `fct_bank_failures`
- Materialization: Table
- Grain: One row per bank failure event (same as source)
- Schema: main

**Transformations:**
- Staging layer: Rename columns to snake_case, convert data types, add surrogate key
- Mart layer: Apply business logic, add calculated fields

**Tests:**
- Staging: not_null + unique on surrogate key, not_null on required fields
- Mart: not_null + unique on primary key, relationships to upstream, data quality checks

## Data Dictionary

### Source Columns (src.bank_failures)
- `c1`: Row ID (BIGINT)
- `Bank`: Bank name (VARCHAR)
- `City`: City of bank headquarters (VARCHAR)
- `State`: State of bank headquarters (VARCHAR)
- `Date`: Failure date (DATE)
- `Acquired by`: Acquiring institution name (VARCHAR)
- `Assets ($mil.)`: Total assets in millions USD (DOUBLE)

### Staging Model (stg_src__bank_failures)
- `bank_failure_id`: Surrogate key (c1 renamed)
- `bank_name`: Bank name
- `bank_city`: City
- `bank_state`: State
- `failure_date`: Failure date
- `acquiring_institution`: Acquiring institution
- `assets_mil`: Total assets in millions

### Mart Model (fct_bank_failures)
- `bank_failure_key`: Primary key (same as bank_failure_id)
- `bank_name`
- `bank_city`
- `bank_state`
- `failure_date`
- `failure_year`: Extracted year
- `failure_quarter`: Extracted quarter (e.g., "2008-Q1")
- `acquiring_institution`
- `assets_mil`
- `is_acquired`: Boolean (TRUE if acquiring institution exists)
