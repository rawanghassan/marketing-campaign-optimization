-- =====================================================
-- Project: Marketing Campaign Optimization
-- Script: Create Raw Marketing Campaign Table
-- =====================================================

DROP TABLE IF EXISTS marketing_campaigns_raw;

CREATE TABLE marketing_campaigns_raw
(
    record_id          VARCHAR(20),
    campaign_date      DATE,
    campaign_id        VARCHAR(20),
    campaign_name      VARCHAR(100),
    channel            VARCHAR(50),
    campaign_type      VARCHAR(50),
    region             VARCHAR(50),
    audience_segment   VARCHAR(100),
    device             VARCHAR(20),
    impressions        INTEGER,
    clicks             INTEGER,
    conversions        INTEGER,
    spend_usd          NUMERIC(12, 2),
    revenue_usd        NUMERIC(14, 2)
);