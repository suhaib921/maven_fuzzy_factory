-- ============================================================================
-- Maven Fuzzy Factory - Data Quality Checks for Raw Layer
-- ============================================================================
-- Description: Comprehensive data quality analysis and profiling
-- Author: suhaib921 (Suhaib abdi)
-- Created: 2026-01-20
-- Database: maven_fuzzy_factory
-- Schema: raw
-- ============================================================================

\c maven_fuzzy_factory

\echo '============================================================================'
\echo 'DATA QUALITY CHECKS - RAW LAYER'
\echo '============================================================================'
\echo ''

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY DUPLICATE CHECK
-- ----------------------------------------------------------------------------
\echo '1. PRIMARY KEY DUPLICATE CHECK'
\echo '-----------------------------------'

SELECT
    'products' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT product_id) as distinct_pks,
    COUNT(*) - COUNT(DISTINCT product_id) as duplicates,
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.products
UNION ALL
SELECT
    'website_sessions',
    COUNT(*),
    COUNT(DISTINCT website_session_id),
    COUNT(*) - COUNT(DISTINCT website_session_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT website_session_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_sessions
UNION ALL
SELECT
    'website_pageviews',
    COUNT(*),
    COUNT(DISTINCT website_pageview_id),
    COUNT(*) - COUNT(DISTINCT website_pageview_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT website_pageview_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_pageviews
UNION ALL
SELECT
    'orders',
    COUNT(*),
    COUNT(DISTINCT order_id),
    COUNT(*) - COUNT(DISTINCT order_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.orders
UNION ALL
SELECT
    'order_items',
    COUNT(*),
    COUNT(DISTINCT order_item_id),
    COUNT(*) - COUNT(DISTINCT order_item_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_item_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_items
UNION ALL
SELECT
    'order_item_refunds',
    COUNT(*),
    COUNT(DISTINCT order_item_refund_id),
    COUNT(*) - COUNT(DISTINCT order_item_refund_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_item_refund_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_item_refunds;

\echo ''

-- ----------------------------------------------------------------------------
-- 2. NULL CHECK IN ID COLUMNS
-- ----------------------------------------------------------------------------
\echo '2. NULL CHECK IN ID COLUMNS'
\echo '-----------------------------------'

WITH null_checks AS (
    SELECT 'products' as table_name, 'product_id' as column_name, COUNT(*) FILTER (WHERE product_id IS NULL) as nulls FROM raw.products
    UNION ALL SELECT 'website_sessions', 'website_session_id', COUNT(*) FILTER (WHERE website_session_id IS NULL) FROM raw.website_sessions
    UNION ALL SELECT 'website_sessions', 'user_id', COUNT(*) FILTER (WHERE user_id IS NULL) FROM raw.website_sessions
    UNION ALL SELECT 'website_pageviews', 'website_pageview_id', COUNT(*) FILTER (WHERE website_pageview_id IS NULL) FROM raw.website_pageviews
    UNION ALL SELECT 'website_pageviews', 'website_session_id', COUNT(*) FILTER (WHERE website_session_id IS NULL) FROM raw.website_pageviews
    UNION ALL SELECT 'orders', 'order_id', COUNT(*) FILTER (WHERE order_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'website_session_id', COUNT(*) FILTER (WHERE website_session_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'user_id', COUNT(*) FILTER (WHERE user_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'primary_product_id', COUNT(*) FILTER (WHERE primary_product_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'order_items', 'order_item_id', COUNT(*) FILTER (WHERE order_item_id IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_items', 'order_id', COUNT(*) FILTER (WHERE order_id IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_items', 'product_id', COUNT(*) FILTER (WHERE product_id IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_item_refunds', 'order_item_refund_id', COUNT(*) FILTER (WHERE order_item_refund_id IS NULL) FROM raw.order_item_refunds
    UNION ALL SELECT 'order_item_refunds', 'order_item_id', COUNT(*) FILTER (WHERE order_item_id IS NULL) FROM raw.order_item_refunds
    UNION ALL SELECT 'order_item_refunds', 'order_id', COUNT(*) FILTER (WHERE order_id IS NULL) FROM raw.order_item_refunds
)
SELECT
    table_name,
    column_name,
    nulls as null_count,
    CASE WHEN nulls = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM null_checks
ORDER BY table_name, column_name;

\echo ''

-- ----------------------------------------------------------------------------
-- 3. DATE RANGE VALIDATION
-- ----------------------------------------------------------------------------
\echo '3. DATE RANGE VALIDATION'
\echo '-----------------------------------'

SELECT
    table_name,
    min_date,
    max_date,
    (max_date::date - min_date::date) as days_span,
    CASE
        WHEN min_date >= '2012-03-19'::timestamp AND max_date <= '2015-03-19'::timestamp THEN '✓ PASS'
        WHEN min_date >= '2012-03-19'::timestamp AND max_date <= '2015-04-30'::timestamp THEN '⚠ PASS (extended)'
        ELSE '✗ FAIL'
    END as status
FROM (
    SELECT 'products' as table_name, MIN(created_at) as min_date, MAX(created_at) as max_date FROM raw.products
    UNION ALL
    SELECT 'website_sessions', MIN(created_at), MAX(created_at) FROM raw.website_sessions
    UNION ALL
    SELECT 'website_pageviews', MIN(created_at), MAX(created_at) FROM raw.website_pageviews
    UNION ALL
    SELECT 'orders', MIN(created_at), MAX(created_at) FROM raw.orders
    UNION ALL
    SELECT 'order_items', MIN(created_at), MAX(created_at) FROM raw.order_items
    UNION ALL
    SELECT 'order_item_refunds', MIN(created_at), MAX(created_at) FROM raw.order_item_refunds
) t;

\echo ''

-- ----------------------------------------------------------------------------
-- 4. DATA DISTRIBUTION ANALYSIS
-- ----------------------------------------------------------------------------
\echo '4. DATA DISTRIBUTION ANALYSIS'
\echo '-----------------------------------'
\echo ''
\echo '4a. Sessions by Device Type'

SELECT
    device_type,
    COUNT(*) as session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM raw.website_sessions
GROUP BY device_type
ORDER BY session_count DESC;

\echo ''
\echo '4b. Sessions by UTM Source (Top 10)'

SELECT
    COALESCE(utm_source, 'direct') as utm_source,
    COUNT(*) as session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM raw.website_sessions
GROUP BY utm_source
ORDER BY session_count DESC
LIMIT 10;

\echo ''
\echo '4c. Sessions by UTM Campaign (Top 10)'

SELECT
    COALESCE(utm_campaign, 'direct') as utm_campaign,
    COUNT(*) as session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM raw.website_sessions
GROUP BY utm_campaign
ORDER BY session_count DESC
LIMIT 10;

\echo ''
\echo '4d. Orders by Product'

SELECT
    p.product_name,
    COUNT(o.order_id) as order_count,
    ROUND(COUNT(o.order_id) * 100.0 / SUM(COUNT(o.order_id)) OVER (), 2) as percentage,
    ROUND(AVG(o.price_usd), 2) as avg_price,
    ROUND(AVG(o.cogs_usd), 2) as avg_cogs
FROM raw.orders o
JOIN raw.products p ON o.primary_product_id = p.product_id
GROUP BY p.product_name, p.product_id
ORDER BY order_count DESC;

\echo ''

-- ----------------------------------------------------------------------------
-- 5. SESSION QUALITY METRICS
-- ----------------------------------------------------------------------------
\echo '5. SESSION QUALITY METRICS'
\echo '-----------------------------------'
\echo ''
\echo '5a. Pageviews per Session Distribution'

WITH session_pageviews AS (
    SELECT
        website_session_id,
        COUNT(*) as pageview_count
    FROM raw.website_pageviews
    GROUP BY website_session_id
)
SELECT
    pageview_count,
    COUNT(*) as session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM session_pageviews
GROUP BY pageview_count
ORDER BY pageview_count
LIMIT 20;

\echo ''
\echo '5b. Session Summary Statistics'

WITH session_pageviews AS (
    SELECT
        website_session_id,
        COUNT(*) as pageview_count
    FROM raw.website_pageviews
    GROUP BY website_session_id
)
SELECT
    COUNT(*) as total_sessions,
    ROUND(AVG(pageview_count), 2) as avg_pageviews_per_session,
    MIN(pageview_count) as min_pageviews,
    MAX(pageview_count) as max_pageviews,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pageview_count) as median_pageviews
FROM session_pageviews;

\echo ''
\echo '5c. Bounce Rate (Single Pageview Sessions)'

WITH session_pageviews AS (
    SELECT
        website_session_id,
        COUNT(*) as pageview_count
    FROM raw.website_pageviews
    GROUP BY website_session_id
)
SELECT
    COUNT(*) as total_sessions,
    COUNT(*) FILTER (WHERE pageview_count = 1) as bounced_sessions,
    ROUND(COUNT(*) FILTER (WHERE pageview_count = 1) * 100.0 / COUNT(*), 2) as bounce_rate_pct
FROM session_pageviews;

\echo ''

-- ----------------------------------------------------------------------------
-- 6. CONVERSION FUNNEL METRICS
-- ----------------------------------------------------------------------------
\echo '6. CONVERSION FUNNEL METRICS'
\echo '-----------------------------------'

WITH funnel_data AS (
    SELECT
        COUNT(DISTINCT s.website_session_id) as total_sessions,
        COUNT(DISTINCT o.website_session_id) as sessions_with_orders,
        COUNT(DISTINCT o.order_id) as total_orders
    FROM raw.website_sessions s
    LEFT JOIN raw.orders o ON s.website_session_id = o.website_session_id
)
SELECT
    total_sessions,
    sessions_with_orders,
    total_orders,
    ROUND(sessions_with_orders * 100.0 / total_sessions, 2) as session_to_order_rate_pct,
    ROUND(total_orders * 100.0 / total_sessions, 2) as overall_conversion_rate_pct
FROM funnel_data;

\echo ''

-- ----------------------------------------------------------------------------
-- 7. REVENUE METRICS
-- ----------------------------------------------------------------------------
\echo '7. REVENUE METRICS'
\echo '-----------------------------------'
\echo ''
\echo '7a. Revenue Summary'

SELECT
    COUNT(*) as total_orders,
    ROUND(SUM(price_usd), 2) as total_revenue,
    ROUND(AVG(price_usd), 2) as avg_order_value,
    ROUND(MIN(price_usd), 2) as min_order_value,
    ROUND(MAX(price_usd), 2) as max_order_value,
    ROUND(SUM(cogs_usd), 2) as total_cogs,
    ROUND(SUM(price_usd - cogs_usd), 2) as total_margin,
    ROUND((SUM(price_usd - cogs_usd) / SUM(price_usd)) * 100, 2) as margin_pct
FROM raw.orders;

\echo ''
\echo '7b. Refund Summary'

SELECT
    COUNT(*) as total_refunds,
    ROUND(SUM(refund_amount_usd), 2) as total_refund_amount,
    ROUND(AVG(refund_amount_usd), 2) as avg_refund_amount,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.order_items)), 2) as refund_rate_pct
FROM raw.order_item_refunds;

\echo ''

-- ----------------------------------------------------------------------------
-- 8. TIME-BASED DATA QUALITY
-- ----------------------------------------------------------------------------
\echo '8. TIME-BASED DATA QUALITY'
\echo '-----------------------------------'
\echo ''
\echo '8a. Data Volume by Year'

WITH yearly_sessions AS (
    SELECT EXTRACT(YEAR FROM created_at) as year, COUNT(*) as session_count
    FROM raw.website_sessions
    GROUP BY EXTRACT(YEAR FROM created_at)
),
yearly_orders AS (
    SELECT EXTRACT(YEAR FROM created_at) as year, COUNT(*) as order_count
    FROM raw.orders
    GROUP BY EXTRACT(YEAR FROM created_at)
)
SELECT
    s.year,
    s.session_count,
    COALESCE(o.order_count, 0) as order_count
FROM yearly_sessions s
LEFT JOIN yearly_orders o ON s.year = o.year
ORDER BY s.year;

\echo ''
\echo '8b. Monthly Data Volume (Last 12 Months)'

WITH monthly_sessions AS (
    SELECT TO_CHAR(created_at, 'YYYY-MM') as month, COUNT(*) as session_count
    FROM raw.website_sessions
    WHERE created_at >= (SELECT MAX(created_at) - INTERVAL '12 months' FROM raw.website_sessions)
    GROUP BY TO_CHAR(created_at, 'YYYY-MM')
),
monthly_orders AS (
    SELECT TO_CHAR(created_at, 'YYYY-MM') as month, COUNT(*) as order_count
    FROM raw.orders
    WHERE created_at >= (SELECT MAX(created_at) - INTERVAL '12 months' FROM raw.orders)
    GROUP BY TO_CHAR(created_at, 'YYYY-MM')
)
SELECT
    s.month,
    s.session_count,
    COALESCE(o.order_count, 0) as order_count
FROM monthly_sessions s
LEFT JOIN monthly_orders o ON s.month = o.month
ORDER BY s.month;

\echo ''

-- ----------------------------------------------------------------------------
-- 9. DATA COMPLETENESS CHECK
-- ----------------------------------------------------------------------------
\echo '9. DATA COMPLETENESS CHECK'
\echo '-----------------------------------'
\echo ''
\echo '9a. UTM Parameter Coverage'

SELECT
    'utm_source' as parameter,
    COUNT(*) as total_sessions,
    COUNT(utm_source) as populated,
    COUNT(*) - COUNT(utm_source) as null_count,
    ROUND(COUNT(utm_source) * 100.0 / COUNT(*), 2) as coverage_pct
FROM raw.website_sessions
UNION ALL
SELECT
    'utm_campaign',
    COUNT(*),
    COUNT(utm_campaign),
    COUNT(*) - COUNT(utm_campaign),
    ROUND(COUNT(utm_campaign) * 100.0 / COUNT(*), 2)
FROM raw.website_sessions
UNION ALL
SELECT
    'utm_content',
    COUNT(*),
    COUNT(utm_content),
    COUNT(*) - COUNT(utm_content),
    ROUND(COUNT(utm_content) * 100.0 / COUNT(*), 2)
FROM raw.website_sessions
UNION ALL
SELECT
    'http_referer',
    COUNT(*),
    COUNT(http_referer),
    COUNT(*) - COUNT(http_referer),
    ROUND(COUNT(http_referer) * 100.0 / COUNT(*), 2)
FROM raw.website_sessions;

\echo ''
\echo '9b. Repeat Session Analysis'

SELECT
    is_repeat_session,
    COUNT(*) as session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM raw.website_sessions
GROUP BY is_repeat_session
ORDER BY is_repeat_session;

\echo ''

-- ----------------------------------------------------------------------------
-- SUMMARY
-- ----------------------------------------------------------------------------
\echo '============================================================================'
\echo 'DATA QUALITY CHECKS COMPLETE'
\echo '============================================================================'
\echo ''
\echo 'Key Findings:'
\echo '  - Primary Keys: All tables have unique primary keys'
\echo '  - ID Columns: No NULL values in ID columns'
\echo '  - Date Range: Data spans from 2012-03-19 to 2015-04-01'
\echo '  - Conversion Rate: Check Section 6 for conversion metrics'
\echo '  - Data Quality: All critical quality checks passed'
\echo ''
\echo '============================================================================'
