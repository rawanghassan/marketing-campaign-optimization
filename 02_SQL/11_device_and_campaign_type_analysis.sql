-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Device and Campaign Type Performance Analysis
-- Section 1: Device Performance
-- =====================================================


WITH device_totals AS
(
    SELECT

        device,

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


    GROUP BY device
),


device_metrics AS
(
    SELECT

        device,

        total_records,

        total_impressions,

        total_clicks,

        total_conversions,


        ROUND
        (
            total_spend_usd,
            2
        ) AS total_spend_usd,


        ROUND
        (
            total_revenue_usd,
            2
        ) AS total_revenue_usd,


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


    FROM device_totals
),


device_ranked AS
(
    SELECT

        DENSE_RANK() OVER
        (
            ORDER BY roi_percentage DESC

        ) AS roi_rank,


        DENSE_RANK() OVER
        (
            ORDER BY total_revenue_usd DESC

        ) AS revenue_rank,


        DENSE_RANK() OVER
        (
            ORDER BY total_conversions DESC

        ) AS conversion_rank,


        *


    FROM device_metrics
)


SELECT

    roi_rank,

    revenue_rank,

    conversion_rank,

    device,

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


    CASE

        WHEN

            roi_rank = 1

            AND

            total_conversions >= 30000

            THEN 'Scale Budget'


        WHEN

            revenue_rank = 1

            AND

            conversion_rank = 1

            THEN 'Protect Volume and Optimize Cost'


        ELSE

            'Review and Optimize'

    END AS device_recommendation


FROM device_ranked


ORDER BY

    roi_rank,

    device;



-- =====================================================
-- Section 2: Campaign Type Performance
-- =====================================================


WITH campaign_type_totals AS
(
    SELECT

        campaign_type,

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


    GROUP BY campaign_type
),


campaign_type_metrics AS
(
    SELECT

        campaign_type,

        total_records,

        total_impressions,

        total_clicks,

        total_conversions,


        ROUND
        (
            total_spend_usd,
            2
        ) AS total_spend_usd,


        ROUND
        (
            total_revenue_usd,
            2
        ) AS total_revenue_usd,


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


    FROM campaign_type_totals
),


campaign_type_ranked AS
(
    SELECT

        DENSE_RANK() OVER
        (
            ORDER BY roi_percentage DESC

        ) AS roi_rank,


        DENSE_RANK() OVER
        (
            ORDER BY total_revenue_usd DESC

        ) AS revenue_rank,


        DENSE_RANK() OVER
        (
            ORDER BY total_conversions DESC

        ) AS conversion_rank,


        *


    FROM campaign_type_metrics
)


SELECT

    roi_rank,

    revenue_rank,

    conversion_rank,

    campaign_type,

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


    CASE

        WHEN

            roas >= 7

            AND

            total_conversions >= 10000

            THEN 'Scale Budget'


        WHEN roas >= 4

            THEN 'Maintain and Optimize'


        WHEN roas >= 2

            THEN 'Review and Optimize'


        ELSE

            'Review Budget and Strategy'

    END AS campaign_type_recommendation


FROM campaign_type_ranked


ORDER BY

    roi_rank,

    campaign_type;	