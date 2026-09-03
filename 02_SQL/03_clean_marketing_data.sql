-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Create Clean Marketing Campaign Table
-- =====================================================


-- =====================================================
-- 1. REMOVE THE CLEAN TABLE IF IT ALREADY EXISTS
-- =====================================================

DROP TABLE IF EXISTS marketing_campaigns_clean;


-- =====================================================
-- 2. CREATE THE CLEAN TABLE
-- =====================================================

CREATE TABLE marketing_campaigns_clean AS

WITH ranked_records AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            PARTITION BY record_id

            ORDER BY
                campaign_date,
                campaign_id,
                campaign_name,
                channel,
                region
        ) AS row_number

    FROM marketing_campaigns_raw
)

SELECT

    -- Clean record ID
    TRIM(record_id)::VARCHAR(20)
        AS record_id,


    -- Campaign date
    campaign_date,


    -- Clean campaign ID
    TRIM(campaign_id)::VARCHAR(20)
        AS campaign_id,


    -- Clean campaign name
    TRIM(campaign_name)::VARCHAR(100)
        AS campaign_name,


    -- Standardize marketing channel names
    CASE

        WHEN LOWER(TRIM(channel)) = 'google ads'
            THEN 'Google Ads'

        WHEN LOWER(TRIM(channel)) = 'meta ads'
            THEN 'Meta Ads'

        WHEN LOWER(TRIM(channel)) = 'linkedin ads'
            THEN 'LinkedIn Ads'

        WHEN LOWER(TRIM(channel)) = 'tiktok ads'
            THEN 'TikTok Ads'

        WHEN LOWER(TRIM(channel)) = 'email'
            THEN 'Email'

        WHEN LOWER(TRIM(channel)) = 'display ads'
            THEN 'Display Ads'

        WHEN LOWER(TRIM(channel)) = 'youtube ads'
            THEN 'YouTube Ads'

        WHEN LOWER(TRIM(channel)) = 'influencer'
            THEN 'Influencer'

        ELSE TRIM(channel)

    END::VARCHAR(50)
        AS channel,


    -- Clean campaign type
    TRIM(campaign_type)::VARCHAR(50)
        AS campaign_type,


    -- Standardize region names
    CASE

        WHEN LOWER(TRIM(region)) = 'north america'
            THEN 'North America'

        WHEN LOWER(TRIM(region)) = 'europe'
            THEN 'Europe'

        WHEN LOWER(TRIM(region)) = 'mena'
            THEN 'MENA'

        WHEN LOWER(TRIM(region)) = 'asia-pacific'
            THEN 'Asia-Pacific'

        WHEN LOWER(TRIM(region)) = 'latin america'
            THEN 'Latin America'

        ELSE TRIM(region)

    END::VARCHAR(50)
        AS region,


    -- Replace missing audience segments
    COALESCE
    (
        NULLIF
        (
            TRIM(audience_segment),
            ''
        ),

        'Unknown'

    )::VARCHAR(100)
        AS audience_segment,


    -- Clean device name
    TRIM(device)::VARCHAR(20)
        AS device,


    -- Marketing performance metrics
    impressions,

    clicks,

    conversions,

    spend_usd,

    revenue_usd


FROM ranked_records

WHERE row_number = 1;

-- =====================================================
-- 3. ADD PRIMARY KEY
-- =====================================================

ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
marketing_campaigns_clean_pk

PRIMARY KEY
(
    record_id
);


-- =====================================================
-- 4. ADD DATA QUALITY CONSTRAINTS
-- =====================================================

ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
valid_impressions

CHECK
(
    impressions >= 0
);


ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
valid_clicks

CHECK
(
    clicks >= 0

    AND

    clicks <= impressions
);


ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
valid_conversions

CHECK
(
    conversions >= 0

    AND

    conversions <= clicks
);


ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
valid_spend

CHECK
(
    spend_usd > 0
);


ALTER TABLE marketing_campaigns_clean

ADD CONSTRAINT
valid_revenue

CHECK
(
    revenue_usd >= 0
);


-- =====================================================
-- 5. UPDATE POSTGRESQL TABLE STATISTICS
-- =====================================================

ANALYZE marketing_campaigns_clean;

-- =====================================================
-- 6. VALIDATE THE CLEANING RESULTS
-- =====================================================

SELECT

    (
        SELECT COUNT(*)

        FROM marketing_campaigns_raw

    ) AS raw_records,


    (
        SELECT COUNT(*)

        FROM marketing_campaigns_clean

    ) AS clean_records,


    (
        SELECT COUNT(*)

        FROM marketing_campaigns_raw

    )

    -

    (
        SELECT COUNT(*)

        FROM marketing_campaigns_clean

    ) AS removed_duplicate_records,


    COUNT
    (
        DISTINCT channel

    ) AS standardized_channels,


    COUNT
    (
        DISTINCT region

    ) AS standardized_regions,


    COUNT(*) FILTER
    (
        WHERE audience_segment = 'Unknown'

    ) AS unknown_audience_segments


FROM marketing_campaigns_clean;