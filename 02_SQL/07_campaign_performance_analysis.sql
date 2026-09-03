-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Individual Campaign Performance Analysis
-- =====================================================


WITH campaign_totals AS
(
    SELECT

        campaign_id,

        campaign_name,

        channel,

        campaign_type,

        COUNT(*)
            AS total_records,

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


    GROUP BY

        campaign_id,

        campaign_name,

        channel,

        campaign_type
),


campaign_metrics AS
(
    SELECT

        campaign_id,

        campaign_name,

        channel,

        campaign_type,

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


        -- Total campaign profit
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


    FROM campaign_totals
)


SELECT

    -- Campaign ranking based on ROI
    DENSE_RANK() OVER
    (
        ORDER BY roi_percentage DESC

    ) AS roi_rank,


    -- Campaign ranking based on revenue
    DENSE_RANK() OVER
    (
        ORDER BY total_revenue_usd DESC

    ) AS revenue_rank,


    campaign_id,

    campaign_name,

    channel,

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


    -- Preliminary campaign recommendation
    CASE

        WHEN roas < 1

            THEN 'Reduce or Pause'


        WHEN

            roas >= 5

            AND

            roi_percentage >= 400

            THEN 'Scale Budget'


        WHEN roas >= 3

            THEN 'Maintain and Optimize'


        ELSE

            'Review and Optimize'

    END AS recommended_action


FROM campaign_metrics


ORDER BY

    roi_rank,

    campaign_id;