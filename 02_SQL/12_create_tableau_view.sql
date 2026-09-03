-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Create Tableau Analytical View
-- =====================================================


-- =====================================================
-- 1. CREATE THE FINAL TABLEAU VIEW
-- =====================================================

CREATE OR REPLACE VIEW
vw_marketing_campaign_tableau
AS

SELECT

    -- Record identifiers
    record_id,

    campaign_id,

    campaign_name,


    -- Original campaign date
    campaign_date,


    -- Date fields prepared for Tableau
    DATE_TRUNC
    (
        'month',
        campaign_date
    )::DATE
        AS month_start,


    EXTRACT
    (
        YEAR
        FROM campaign_date
    )::INTEGER
        AS campaign_year,


    EXTRACT
    (
        MONTH
        FROM campaign_date
    )::INTEGER
        AS campaign_month_number,


    TO_CHAR
    (
        campaign_date,
        'Month'
    )
        AS campaign_month_name,


    TO_CHAR
    (
        campaign_date,
        'YYYY-MM'
    )
        AS year_month,


    CONCAT
    (
        'Q',

        EXTRACT
        (
            QUARTER
            FROM campaign_date
        )::INTEGER

    )
        AS campaign_quarter,


    -- Marketing dimensions
    channel,

    campaign_type,

    region,

    audience_segment,

    device,


    -- Marketing activity metrics
    impressions,

    clicks,

    conversions,


    -- Financial metrics
    spend_usd,

    revenue_usd,


    -- Profit
    ROUND
    (
        revenue_usd
        -
        spend_usd,

        2

    )
        AS profit_usd,


    -- Row-level profit margin
    ROUND
    (
        (
            revenue_usd
            -
            spend_usd
        )

        /

        NULLIF
        (
            revenue_usd,
            0
        )

        * 100,

        2

    )
        AS row_profit_margin_percentage


FROM marketing_campaigns_clean;


-- =====================================================
-- 2. VALIDATE THE TABLEAU VIEW
-- =====================================================

SELECT

    COUNT(*)
        AS total_records,

    COUNT(DISTINCT record_id)
        AS unique_record_ids,

    COUNT(DISTINCT campaign_id)
        AS total_campaigns,

    COUNT(DISTINCT channel)
        AS total_channels,

    COUNT(DISTINCT region)
        AS total_regions,

    MIN(campaign_date)
        AS earliest_date,

    MAX(campaign_date)
        AS latest_date,

    ROUND
    (
        SUM(spend_usd),
        2
    )
        AS total_spend_usd,

    ROUND
    (
        SUM(revenue_usd),
        2
    )
        AS total_revenue_usd,

    ROUND
    (
        SUM(profit_usd),
        2
    )
        AS total_profit_usd


FROM vw_marketing_campaign_tableau;



-- Preview Tableau-ready records

SELECT *
FROM vw_marketing_campaign_tableau
ORDER BY campaign_date,
         record_id
LIMIT 10;