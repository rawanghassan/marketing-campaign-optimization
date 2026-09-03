-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Validate Clean Marketing Data
-- =====================================================


-- =====================================================
-- 1. FINAL CLEANING VALIDATION SUMMARY
-- =====================================================

SELECT

    -- Number of records before cleaning
    (
        SELECT COUNT(*)
        FROM marketing_campaigns_raw
    ) AS raw_records,


    -- Number of records after cleaning
    (
        SELECT COUNT(*)
        FROM marketing_campaigns_clean
    ) AS clean_records,


    -- Number of removed duplicate records
    (
        SELECT COUNT(*)
        FROM marketing_campaigns_raw
    )
    -
    (
        SELECT COUNT(*)
        FROM marketing_campaigns_clean
    ) AS removed_duplicates,


    -- Check remaining duplicate record IDs
    COUNT(*)
    -
    COUNT(DISTINCT record_id)
        AS remaining_duplicates,


    -- Check rows containing missing values
    COUNT(*) FILTER
    (
        WHERE

            record_id IS NULL
            OR TRIM(record_id) = ''

            OR campaign_date IS NULL

            OR campaign_id IS NULL
            OR TRIM(campaign_id) = ''

            OR campaign_name IS NULL
            OR TRIM(campaign_name) = ''

            OR channel IS NULL
            OR TRIM(channel) = ''

            OR campaign_type IS NULL
            OR TRIM(campaign_type) = ''

            OR region IS NULL
            OR TRIM(region) = ''

            OR audience_segment IS NULL
            OR TRIM(audience_segment) = ''

            OR device IS NULL
            OR TRIM(device) = ''

            OR impressions IS NULL

            OR clicks IS NULL

            OR conversions IS NULL

            OR spend_usd IS NULL

            OR revenue_usd IS NULL
    ) AS rows_with_missing_values,


    -- Check invalid marketing metrics
    COUNT(*) FILTER
    (
        WHERE

            impressions < 0

            OR clicks < 0

            OR conversions < 0

            OR spend_usd <= 0

            OR revenue_usd < 0

            OR clicks > impressions

            OR conversions > clicks
    ) AS invalid_metric_rows,


    -- Number of standardized marketing channels
    COUNT(DISTINCT channel)
        AS total_channels,


    -- Number of standardized regions
    COUNT(DISTINCT region)
        AS total_regions,


    -- Replaced missing audience values
    COUNT(*) FILTER
    (
        WHERE audience_segment = 'Unknown'
    ) AS unknown_audience_segments,


    -- Dataset date range
    MIN(campaign_date)
        AS earliest_date,


    MAX(campaign_date)
        AS latest_date


FROM marketing_campaigns_clean;




-- =====================================================
-- 2. REVIEW STANDARDIZED CHANNELS AND REGIONS
-- =====================================================

SELECT

    'Marketing Channel' AS category,

    channel AS standardized_value,

    COUNT(*) AS total_records

FROM marketing_campaigns_clean

GROUP BY channel


UNION ALL


SELECT

    'Region' AS category,

    region AS standardized_value,

    COUNT(*) AS total_records

FROM marketing_campaigns_clean

GROUP BY region


ORDER BY

    category,

    standardized_value;