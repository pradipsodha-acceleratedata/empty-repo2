{{ config(
  materialized='table',
  contract={'enforced': true}
) }}

WITH

-- Import CTE: source account data
source_account AS (
  SELECT * FROM {{ source('src_salescloud', 'account') }}
),

-- Logical CTE: transform and rename columns
transformed AS (
  SELECT
    Id AS account_id,
    Name AS account_name,
    Type AS account_type,
    Industry AS industry,
    AnnualRevenue AS annual_revenue,
    NumberOfEmployees AS employee_count,
    Phone AS phone,
    Website AS website,
    AccountNumber AS account_number,
    AccountSource AS account_source,
    Rating AS rating,
    Ownership AS ownership,
    BillingStreet AS billing_street,
    BillingCity AS billing_city,
    BillingState AS billing_state,
    BillingPostalCode AS billing_postal_code,
    BillingCountry AS billing_country,
    ShippingStreet AS shipping_street,
    ShippingCity AS shipping_city,
    ShippingState AS shipping_state,
    ShippingPostalCode AS shipping_postal_code,
    ShippingCountry AS shipping_country,
    Description AS account_description,
    OwnerId AS owner_id,
    ParentId AS parent_account_id,
    CAST(IsCustomerPortal AS BOOLEAN) AS is_customer_portal,
    CAST(IsPartner AS BOOLEAN) AS is_partner,
    CAST(CreatedDate AS TIMESTAMP) AS created_date,
    CAST(LastModifiedDate AS TIMESTAMP) AS last_modified_date,
    CAST(LastActivityDate AS DATE) AS last_activity_date
  FROM source_account
),

-- Final CTE: grain assertion, add control columns
-- One row per account
final AS (
  SELECT
    account_id,
    account_name,
    account_type,
    industry,
    annual_revenue,
    employee_count,
    phone,
    website,
    account_number,
    account_source,
    rating,
    ownership,
    billing_street,
    billing_city,
    billing_state,
    billing_postal_code,
    billing_country,
    shipping_street,
    shipping_city,
    shipping_state,
    shipping_postal_code,
    shipping_country,
    account_description,
    owner_id,
    parent_account_id,
    is_customer_portal,
    is_partner,
    created_date,
    last_modified_date,
    last_activity_date,
    CURRENT_TIMESTAMP AS _loaded_at,
    '{{ invocation_id }}' AS _dbt_invocation_id
  FROM transformed
)

SELECT * FROM final
