-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Audience Segment Performance Analysis
-- =====================================================


WITH audience_totals AS
(
    SELECT

        audience_segment,

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


    GROUP BY audience_segment
),


audience_metrics AS
(
    SELECT

        audience_segment,

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


    FROM audience_totals
)


SELECT

    -- Ranking based on ROI
    DENSE_RANK() OVER
    (
        ORDER BY roi_percentage DESC

    ) AS roi_rank,


    -- Ranking based on revenue
    DENSE_RANK() OVER
    (
        ORDER BY total_revenue_usd DESC

    ) AS revenue_rank,


    -- Ranking based on conversions
    DENSE_RANK() OVER
    (
        ORDER BY total_conversions DESC

    ) AS conversion_rank,


    audience_segment,

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


    -- Audience-level recommendation
    CASE

        WHEN audience_segment = 'Unknown'

            THEN 'Review Data Quality'


        WHEN

            roi_percentage >= 700

            AND

            total_conversions >= 10000

            THEN 'High-Value Segment'


        WHEN roi_percentage >= 300

            THEN 'Growth Opportunity'


        ELSE

            'Optimize Targeting'

    END AS segment_recommendation


FROM audience_metrics


ORDER BY

    roi_rank,

    audience_segment;