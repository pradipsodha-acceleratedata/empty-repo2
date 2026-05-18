# Sales Data Mart - Design Document

## Progress

| Phase / Gate | Date | Notes |
|---|---|---|
| Phase 0 — Intent classification | 2026-05-18 | Classified as work/transformation |
| Phase 0 — Intent approval | 2026-05-18 | User confirmed scope: accounts/customers, transaction-level grain |
| Phase 1 — Workspace scaffolding | 2026-05-18 | dbt project created, Spark cluster connected |
| Phase 2 — Requirements | | |
| Phase 3a — Plan skeleton + change-impact | 2026-05-18 | Fresh build, no existing models |
| Phase 3b — Specialized design (medallion) | | |
| Phase 3 — Design approval | | |
| Phase 4a — Generate models | | |
| Phase 4b — Unit tests | | |
| Phase 4c — Data tests | | |
| Phase 4d — Validation (golden data) | | |
| Phase 4d.5 — Audit (dbt-project-evaluator) | | |
| Phase 4e — Contract authoring | | |
| Phase 4f — Code review | | |
| Phase 5a — Schema delta approval | | |
| Phase 5b — Documentation | | |
| Phase 5c — Author Fabric notebook | | |
| Phase 5d — Validate Fabric notebook | | |
| Phase 5e — PR workflow | | |

## Model Inventory

| Model | Layer | Materialization | Grain | Primary Key | Status | Notes |
|---|---|---|---|---|---|---|
| dim_account | marts | table | One row per account | account_id | pending | Account/customer dimension |
| fct_sales | marts | table | One row per opportunity | opportunity_id | pending | Sales opportunity fact table |

## Source Tables

| Schema | Table | Description | Usage |
|---|---|---|---|
| src_salescloud | account | Salesforce Account object (raw) | Source for dim_account |
| src_salescloud | opportunity | Salesforce Opportunity object (raw) | Source for fct_sales |
| dbo | stg_accounts | Staging view of accounts | Alternative source (if exists) |

## Change Impact

No existing artifacts impacted — fresh build target.

## Business Requirements

Based on intent.md and user responses:

### Scope
- **Entities:** Accounts/Customers
- **Fact Grain:** Transaction/opportunity level (one row per sales opportunity)
- **Source System:** Salesforce Sales Cloud (src_salescloud schema)
- **Target Platform:** Microsoft Fabric (kuruma_dev_lake lakehouse, dbo schema)

### Models to Create

#### 1. dim_account (Customer/Account Dimension)
- **Purpose:** Provide customer/account attributes for sales analysis
- **Grain:** One row per account (Type 1 SCD - current state only)
- **Key Attributes:**
  - account_id (PK)
  - account_name
  - account_type
  - industry
  - billing geography (city, state, country)
  - account characteristics (annual_revenue, employee_count)
  - account classification (rating, ownership)
  - temporal attributes (created_date, last_modified_date)

#### 2. fct_sales (Sales Opportunity Fact)
- **Purpose:** Track sales opportunities for pipeline and revenue analysis
- **Grain:** One row per opportunity
- **Key Attributes:**
  - opportunity_id (PK)
  - account_id (FK to dim_account)
  - Measures:
    - amount (opportunity value)
    - expected_revenue
    - probability
  - Dimensions:
    - stage_name (current pipeline stage)
    - close_date
    - created_date
    - owner_id
    - lead_source
    - opportunity_type
  - Flags:
    - is_closed
    - is_won
    - is_closed_won (derived)

### Data Quality Requirements

Per AGENTS.md standards:

1. **Primary Key Tests:**
   - dim_account.account_id: not_null, unique
   - fct_sales.opportunity_id: not_null, unique

2. **Foreign Key Tests:**
   - fct_sales.account_id → dim_account.account_id (relationships test)

3. **Business Logic Tests:**
   - is_closed_won = TRUE only when is_closed = TRUE AND is_won = TRUE
   - Amount > 0 for closed-won opportunities
   - close_date not null for closed opportunities

4. **Tolerance Thresholds:**
   - Row count: ±2% acceptable, ±10% fails build
   - Currency amounts: ±$1,000 or 1% acceptable, ±5% fails build

## Artifact List

Files to be created:

### dbt Models
- `models/marts/dim_account.sql` - Account dimension model
- `models/marts/fct_sales.sql` - Sales opportunity fact model

### Schema YAML
- `models/marts/schema.yml` - Model and column documentation, tests, contracts

### Tests (if applicable)
- Unit tests for complex business logic (e.g., is_closed_won derivation)
- Data quality tests beyond standard schema tests

## Open Design Questions

1. **Slowly Changing Dimensions:** Should dim_account track historical changes (Type 2 SCD) or only current state (Type 1)?
   - **Recommendation:** Start with Type 1 (current state only) for simplicity
   - Can enhance to Type 2 in a future iteration if historical tracking is needed

2. **Additional Dimensions:** Should we include related dimensions?
   - Owner/User dimension (sales rep information)
   - Date dimension (for time-based analysis)
   - Product dimension (if opportunity line items are in scope)
   - **Current scope:** Account dimension only; others deferred

3. **Opportunity History:** Should we track opportunity stage changes over time?
   - src_salescloud.opportunityhistory table is available
   - **Recommendation:** Defer to future iteration unless user requests it

4. **Aggregations:** Should we create pre-aggregated summary tables?
   - Daily/monthly revenue rollups
   - Pipeline snapshots
   - **Recommendation:** Start with granular fct_sales; add aggregations based on query patterns
