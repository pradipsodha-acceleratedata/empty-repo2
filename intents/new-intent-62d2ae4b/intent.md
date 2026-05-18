# Sales Data Mart Intent

## Goal

Create a sales data mart for the Delta bytes sales domain to enable business analytics on sales performance. The mart will transform raw/staging data into fact and dimension tables following the medallion architecture (gold layer), providing a clean, modeled view of sales data for reporting and analysis.

## Source System

**TBD** - Need to clarify the source layer:
- Are bronze/staging tables already available in the lakehouse?
- If not, which source system should we ingest from (Salesforce, QuickBooks, PostgreSQL, etc.)?

## Target

- **Platform:** Microsoft Fabric
- **Workspace:** vd-dbt-fabricspark-dev
- **Lakehouse:** kuruma_dev_lake
- **Schema:** dbo
- **Layer:** Marts (Gold)

## Objects in Scope

**TBD** - Need to clarify which sales entities to include. Typical sales mart entities:
- Opportunities/Deals
- Accounts/Customers
- Contacts/Leads
- Products
- Sales stages/pipeline
- Revenue/transactions

## Success Criteria

1. **Model Structure:**
   - Fact tables following `fct_{process}` naming convention
   - Dimension tables following `dim_{entity}` naming convention
   - Table materialization (not views)
   - Star schema design where appropriate

2. **Data Quality:**
   - All primary keys have `not_null` and `unique` tests
   - All foreign keys have `relationships` tests
   - Data validation passing within tolerance:
     - Row count: ±2% acceptable, ±10% fails build
     - Currency amounts: ±$1,000 or 1% acceptable, ±5% fails build

3. **Documentation:**
   - All models have grain-stating descriptions
   - All columns documented
   - Business logic documented in schema YAML

4. **Testing:**
   - dbt build passes successfully
   - Unit tests for complex business logic (if applicable)

## Out of Scope

**TBD** - Pending scope clarification. Potentially:
- Data ingestion (if bronze layer doesn't exist yet)
- Semantic layer / metric definitions
- Specific downstream reporting/BI tool integration

## Open Questions

1. **Source Data Availability:**
   - Are bronze/staging tables already in place in the lakehouse?
   - If not, which source system should we ingest from first?

2. **Entity Scope:**
   - What specific sales entities should be included (opportunities, accounts, contacts, products, etc.)?
   - What is the priority order if implementing incrementally?

3. **Business Metrics:**
   - What KPIs/metrics are needed (revenue, pipeline value, win rates, sales cycle time, etc.)?
   - Are there specific business rules for calculating these metrics?

4. **Grain and Granularity:**
   - What grain should the fact table(s) have (transaction-level, daily aggregates, opportunity snapshots)?
   - What time dimensions are needed (date, month, quarter, fiscal periods)?

5. **Dimensions:**
   - What dimensional attributes are important for slicing/dicing (geography, product category, sales rep, customer segment)?
   - Are slowly changing dimensions (SCD Type 2) needed for any entities?

6. **Data Lineage:**
   - What is the refresh cadence (daily at 6 AM UTC, hourly, real-time)?
   - What is the historical data requirement?
