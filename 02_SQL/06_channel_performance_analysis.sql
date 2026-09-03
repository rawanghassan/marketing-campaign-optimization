-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Marketing Channel Performance Analysis
-- =====================================================


SELECT

    -- Marketing channel
    channel,


    -- Number of campaign records
    COUNT(*) AS total_records,


    -- Total impressions
    SUM(impressions)
        AS total_impressions,


    -- Total clicks
    SUM(clicks)
        AS total_clicks,


    -- Total conversions
    SUM(conversions)
        AS total_conversions,


    -- Total marketing spend
    ROUND
    (
        SUM(spend_usd),
        2
    ) AS total_spend_usd,


    -- Total generated revenue
    ROUND
    (
        SUM(revenue_usd),
        2
    ) AS total_revenue_usd,


    -- Total profit
    ROUND
    (
        SUM(revenue_usd)
        -
        SUM(spend_usd),

        2
    ) AS total_profit_usd,


    -- Click-Through Rate
    ROUND
    (
        SUM(clicks)::NUMERIC

        /

        NULLIF
        (
            SUM(impressions),
            0
        )

        * 100,

        2

    ) AS ctr_percentage,


    -- Conversion Rate
    ROUND
    (
        SUM(conversions)::NUMERIC

        /

        NULLIF
        (
            SUM(clicks),
            0
        )

        * 100,

        2

    ) AS conversion_rate_percentage,


    -- Cost per Click
    ROUND
    (
        SUM(spend_usd)

        /

        NULLIF
        (
            SUM(clicks),
            0
        ),

        2

    ) AS cost_per_click_usd,


    -- Cost per Conversion
    ROUND
    (
        SUM(spend_usd)

        /

        NULLIF
        (
            SUM(conversions),
            0
        ),

        2

    ) AS cost_per_conversion_usd,


    -- Return on Ad Spend
    ROUND
    (
        SUM(revenue_usd)

        /

        NULLIF
        (
            SUM(spend_usd),
            0
        ),

        2

    ) AS roas,


    -- Return on Investment
    ROUND
    (
        (
            SUM(revenue_usd)
            -
            SUM(spend_usd)
        )

        /

        NULLIF
        (
            SUM(spend_usd),
            0
        )

        * 100,

        2

    ) AS roi_percentage


FROM marketing_campaigns_clean


GROUP BY channel


ORDER BY

    roi_percentage DESC;