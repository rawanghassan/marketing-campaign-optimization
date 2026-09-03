-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Monthly Marketing Trend Analysis
-- =====================================================


WITH monthly_totals AS
(
    SELECT

        -- First day of each month
        DATE_TRUNC
        (
            'month',
            campaign_date
        )::DATE AS month_start,


        -- Number of monthly campaign records
        COUNT(*)
            AS total_records,


        -- Monthly marketing activity
        SUM(impressions)
            AS total_impressions,

        SUM(clicks)
            AS total_clicks,

        SUM(conversions)
            AS total_conversions,


        -- Monthly financial totals
        SUM(spend_usd)
            AS total_spend_usd,

        SUM(revenue_usd)
            AS total_revenue_usd


    FROM marketing_campaigns_clean


    GROUP BY

        DATE_TRUNC
        (
            'month',
            campaign_date
        )
),


monthly_metrics AS
(
    SELECT

        month_start,


        -- Display month name
        TO_CHAR
        (
            month_start,
            'Mon YYYY'
        ) AS month_label,


        total_records,

        total_impressions,

        total_clicks,

        total_conversions,


        -- Total monthly spend
        ROUND
        (
            total_spend_usd,
            2
        ) AS total_spend_usd,


        -- Total monthly revenue
        ROUND
        (
            total_revenue_usd,
            2
        ) AS total_revenue_usd,


        -- Monthly profit
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


    FROM monthly_totals
),


monthly_trends AS
(
    SELECT

        *,


        -- Previous month's revenue
        LAG
        (
            total_revenue_usd
        ) OVER
        (
            ORDER BY month_start

        ) AS previous_month_revenue,


        -- Previous month's spend
        LAG
        (
            total_spend_usd
        ) OVER
        (
            ORDER BY month_start

        ) AS previous_month_spend


    FROM monthly_metrics
)


SELECT

    month_start,

    month_label,

    total_records,

    total_impressions,

    total_clicks,

    total_conversions,

    total_spend_usd,

    total_revenue_usd,

    total_profit_usd,

    ctr_percentage,

    conversion_rate_percentage,

    cost_per_conversion_usd,

    roas,

    roi_percentage,


    -- Month-over-Month revenue change
    ROUND
    (
        (
            total_revenue_usd
            -
            previous_month_revenue
        )

        /

        NULLIF
        (
            previous_month_revenue,
            0
        )

        * 100,

        2

    ) AS revenue_mom_change_percentage,


    -- Month-over-Month spend change
    ROUND
    (
        (
            total_spend_usd
            -
            previous_month_spend
        )

        /

        NULLIF
        (
            previous_month_spend,
            0
        )

        * 100,

        2

    ) AS spend_mom_change_percentage,


    -- Monthly performance status
    CASE

        WHEN previous_month_revenue IS NULL

            THEN 'Starting Month'


        WHEN

            total_revenue_usd
            >
            previous_month_revenue

            AND

            roi_percentage >= 650

            THEN 'Strong Growth'


        WHEN

            total_revenue_usd
            >
            previous_month_revenue

            THEN 'Revenue Growth'


        WHEN roi_percentage >= 650

            THEN 'Efficient but Lower Revenue'


        ELSE

            'Review Performance'

    END AS monthly_performance_status


FROM monthly_trends


ORDER BY

    month_start;