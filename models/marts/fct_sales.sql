{{ config(
  materialized='table',
  contract={'enforced': true}
) }}

WITH

-- Import CTEs: one per source
source_opportunity AS (
  SELECT * FROM {{ source('src_salescloud', 'opportunity') }}
),

source_account AS (
  SELECT * FROM {{ ref('dim_account') }}
),

-- Logical CTE: transform and enrich opportunities
transformed AS (
  SELECT
    opp.Id AS opportunity_id,
    opp.Name AS opportunity_name,
    opp.AccountId AS account_id,
    opp.Amount AS amount,
    opp.CloseDate AS close_date,
    opp.StageName AS stage_name,
    opp.Probability AS probability_percent,
    opp.ForecastCategory AS forecast_category,
    opp.ExpectedRevenue AS expected_revenue,
    CAST(opp.IsClosed AS BOOLEAN) AS is_closed,
    CAST(opp.IsWon AS BOOLEAN) AS is_won,
    -- Derived business logic: is_closed_won
    CASE
      WHEN CAST(opp.IsClosed AS BOOLEAN) = TRUE
       AND CAST(opp.IsWon AS BOOLEAN) = TRUE
      THEN TRUE
      ELSE FALSE
    END AS is_closed_won,
    opp.Type AS opportunity_type,
    opp.LeadSource AS lead_source,
    opp.CampaignId AS campaign_id,
    opp.ContactId AS contact_id,
    opp.Pricebook2Id AS pricebook_id,
    opp.OwnerId AS owner_id,
    opp.Description AS opportunity_description,
    opp.NextStep AS next_step,
    CAST(opp.HasOpportunityLineItem AS BOOLEAN) AS has_line_items,
    opp.CurrencyIsoCode AS currency_code,
    CAST(opp.CreatedDate AS TIMESTAMP) AS created_date,
    CAST(opp.LastModifiedDate AS TIMESTAMP) AS last_modified_date,
    CAST(opp.LastStageChangeDate AS TIMESTAMP) AS last_stage_change_date
  FROM source_opportunity AS opp
),

-- Final CTE: grain assertion, validate FK, add control columns
-- One row per sales opportunity
final AS (
  SELECT
    t.opportunity_id,
    t.opportunity_name,
    t.account_id,
    t.amount,
    t.close_date,
    t.stage_name,
    t.probability_percent,
    t.forecast_category,
    t.expected_revenue,
    t.is_closed,
    t.is_won,
    t.is_closed_won,
    t.opportunity_type,
    t.lead_source,
    t.campaign_id,
    t.contact_id,
    t.pricebook_id,
    t.owner_id,
    t.opportunity_description,
    t.next_step,
    t.has_line_items,
    t.currency_code,
    t.created_date,
    t.last_modified_date,
    t.last_stage_change_date,
    CURRENT_TIMESTAMP AS _loaded_at,
    '{{ invocation_id }}' AS _dbt_invocation_id
  FROM transformed AS t
  -- Validate FK: ensure account exists in dim_account
  INNER JOIN source_account AS a
    ON t.account_id = a.account_id
)

SELECT * FROM final
