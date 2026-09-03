-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Data Quality Assessment
-- =====================================================


-- =====================================================
-- 1. DATASET OVERVIEW
-- =====================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT record_id) AS unique_record_ids,
    COUNT(DISTINCT campaign_id) AS total_campaigns,
    MIN(campaign_date) AS earliest_campaign_date,
    MAX(campaign_date) AS latest_campaign_date
FROM marketing_campaigns_raw;


-- =====================================================
-- 2. CHECK MISSING VALUES
-- =====================================================

SELECT
    COUNT(*) FILTER
    (
        WHERE record_id IS NULL
        OR TRIM(record_id) = ''
    ) AS missing_record_id,

    COUNT(*) FILTER
    (
        WHERE campaign_date IS NULL
    ) AS missing_campaign_date,

    COUNT(*) FILTER
    (
        WHERE campaign_id IS NULL
        OR TRIM(campaign_id) = ''
    ) AS missing_campaign_id,

    COUNT(*) FILTER
    (
        WHERE campaign_name IS NULL
        OR TRIM(campaign_name) = ''
    ) AS missing_campaign_name,

    COUNT(*) FILTER
    (
        WHERE channel IS NULL
        OR TRIM(channel) = ''
    ) AS missing_channel,

    COUNT(*) FILTER
    (
        WHERE campaign_type IS NULL
        OR TRIM(campaign_type) = ''
    ) AS missing_campaign_type,

    COUNT(*) FILTER
    (
        WHERE region IS NULL
        OR TRIM(region) = ''
    ) AS missing_region,

    COUNT(*) FILTER
    (
        WHERE audience_segment IS NULL
        OR TRIM(audience_segment) = ''
    ) AS missing_audience_segment,

    COUNT(*) FILTER
    (
        WHERE device IS NULL
        OR TRIM(device) = ''
    ) AS missing_device

FROM marketing_campaigns_raw;


-- =====================================================
-- 3. CHECK DUPLICATE RECORD IDS
-- =====================================================

SELECT
    COUNT(*) - COUNT(DISTINCT record_id)
        AS duplicate_record_count
FROM marketing_campaigns_raw;


-- =====================================================
-- 4. DISPLAY DUPLICATE RECORD IDS
-- =====================================================

SELECT
    record_id,
    COUNT(*) AS occurrence_count
FROM marketing_campaigns_raw
GROUP BY record_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC,
         record_id;


-- =====================================================
-- 5. REVIEW CHANNEL VALUES
-- =====================================================

SELECT
    channel,
    COUNT(*) AS total_records
FROM marketing_campaigns_raw
GROUP BY channel
ORDER BY LOWER(TRIM(channel)),
         channel;


-- =====================================================
-- 6. COUNT RAW AND STANDARDIZED CHANNEL VALUES
-- =====================================================

SELECT
    COUNT(DISTINCT channel)
        AS raw_channel_values,

    COUNT(
        DISTINCT LOWER(TRIM(channel))
    ) AS standardized_channel_values

FROM marketing_campaigns_raw;


-- =====================================================
-- 7. REVIEW REGION VALUES
-- =====================================================

SELECT
    region,
    COUNT(*) AS total_records
FROM marketing_campaigns_raw
GROUP BY region
ORDER BY LOWER(TRIM(region)),
         region;


-- =====================================================
-- 8. COUNT RAW AND STANDARDIZED REGION VALUES
-- =====================================================

SELECT
    COUNT(DISTINCT region)
        AS raw_region_values,

    COUNT(
        DISTINCT LOWER(TRIM(region))
    ) AS standardized_region_values

FROM marketing_campaigns_raw;


-- =====================================================
-- 9. CHECK INVALID MARKETING METRICS
-- =====================================================

SELECT
    COUNT(*) FILTER
    (
        WHERE impressions < 0
    ) AS negative_impressions,

    COUNT(*) FILTER
    (
        WHERE clicks < 0
    ) AS negative_clicks,

    COUNT(*) FILTER
    (
        WHERE conversions < 0
    ) AS negative_conversions,

    COUNT(*) FILTER
    (
        WHERE spend_usd <= 0
    ) AS invalid_spend,

    COUNT(*) FILTER
    (
        WHERE revenue_usd < 0
    ) AS negative_revenue,

    COUNT(*) FILTER
    (
        WHERE clicks > impressions
    ) AS clicks_above_impressions,

    COUNT(*) FILTER
    (
        WHERE conversions > clicks
    ) AS conversions_above_clicks

FROM marketing_campaigns_raw;

-- =====================================================
-- 9. CHECK missing_audience_segment
-- =====================================================

SELECT
    COUNT(*) FILTER
    (
        WHERE audience_segment IS NULL
        OR TRIM(audience_segment) = ''
    ) AS missing_audience_segment
FROM marketing_campaigns_raw;