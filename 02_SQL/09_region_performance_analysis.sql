-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Regional Marketing Performance Analysis
-- =====================================================


WITH region_totals AS
(
    SELECT

        region,

        COUNT(*) AS total_records,

        SUM(impressions)
            AS total_impressions,

        SUM(clicks)
            AS total_clicks,

        SUM(conversions)
            AS total_conversions,

        SUM(spend_usd)
            AS total_spend_usd,

        SUM(revenue_usd)
            AS total_revenue_usd


    FROM marketing_campaigns_clean


    GROUP BY region
),


region_metrics AS
(
    SELECT

        region,

        total_records,

        total_impressions,

        total_clicks,

        total_conversions,


        -- Total marketing spend
        ROUND
        (
            total_spend_usd,
            2
        ) AS total_spend_usd,


        -- Total generated revenue
        ROUND
        (
            total_revenue_usd,
            2
        ) AS total_revenue_usd,


        -- Total generated profit
        ROUND
        (
            total_revenue_usd
            -
            total_spend_usd,

            2
        ) AS total_profit_usd,


        -- Click-Through Rate
        ROUND
        (
            total_clicks::NUMERIC

            /

            NULLIF
            (
                total_impressions,
                0
            )

            * 100,

            2

        ) AS ctr_percentage,


        -- Conversion Rate
        ROUND
        (
            total_conversions::NUMERIC

            /

            NULLIF
            (
                total_clicks,
                0
            )

            * 100,

            2

        ) AS conversion_rate_percentage,


        -- Cost per Click
        ROUND
        (
            total_spend_usd

            /

            NULLIF
            (
                total_clicks,
                0
            ),

            2

        ) AS cost_per_click_usd,


        -- Cost per Conversion
        ROUND
        (
            total_spend_usd

            /

            NULLIF
            (
                total_conversions,
                0
            ),

            2

        ) AS cost_per_conversion_usd,


        -- Return on Ad Spend
        ROUND
        (
            total_revenue_usd

            /

            NULLIF
            (
                total_spend_usd,
                0
            ),

            2

        ) AS roas,


        -- Return on Investment
        ROUND
        (
            (
                total_revenue_usd
                -
                total_spend_usd
            )

            /

            NULLIF
            (
                total_spend_usd,
                0
            )

            * 100,

            2

        ) AS roi_percentage


    FROM region_totals
),


-- =====================================================
-- Calculate regional rankings
-- =====================================================

region_ranked AS
(
    SELECT

        -- Rank regions by ROI
        DENSE_RANK() OVER
        (
            ORDER BY roi_percentage DESC

        ) AS roi_rank,


        -- Rank regions by revenue
        DENSE_RANK() OVER
        (
            ORDER BY total_revenue_usd DESC

        ) AS revenue_rank,


        -- Rank regions by conversions
        DENSE_RANK() OVER
        (
            ORDER BY total_conversions DESC

        ) AS conversion_rank,


        region,

        total_records,

        total_impressions,

        total_clicks,

        total_conversions,

        total_spend_usd,

        total_revenue_usd,

        total_profit_usd,

        ctr_percentage,

        conversion_rate_percentage,

        cost_per_click_usd,

        cost_per_conversion_usd,

        roas,

        roi_percentage


    FROM region_metrics
)


-- =====================================================
-- Final regional performance output
-- =====================================================

SELECT

    roi_rank,

    revenue_rank,

    conversion_rank,

    region,

    total_records,

    total_impressions,

    total_clicks,

    total_conversions,

    total_spend_usd,

    total_revenue_usd,

    total_profit_usd,

    ctr_percentage,

    conversion_rate_percentage,

    cost_per_click_usd,

    cost_per_conversion_usd,

    roas,

    roi_percentage,


    -- Regional budget recommendation
    CASE

        WHEN region = 'Latin America'

            THEN 'Scale Carefully'


        WHEN

            roi_percentage >= 700

            AND

            total_conversions >= 20000

            THEN 'Scale Budget'


        WHEN

            revenue_rank = 1

            AND

            roi_percentage < 600

            THEN 'Protect Volume and Optimize Cost'


        ELSE

            'Maintain and Optimize'

    END AS regional_recommendation


FROM region_ranked


ORDER BY

    roi_rank,

    region;