-- ============================================================================
-- Maven Fuzzy Factory - Raw Data Validation Report
-- ============================================================================
-- Description: Comprehensive data quality checks for raw layer tables
-- Author: suhaib921 (Suhaib abdi)
-- Created: 2026-01-20
-- Database: maven_fuzzy_factory
-- Schema: raw
-- ============================================================================

\c maven_fuzzy_factory

\echo '============================================================================'
\echo 'RAW DATA VALIDATION REPORT'
\echo '============================================================================'
\echo ''

-- ----------------------------------------------------------------------------
-- 1. ROW COUNT VALIDATION
-- ----------------------------------------------------------------------------
\echo '1. ROW COUNT VALIDATION'
\echo '-----------------------------------'

SELECT
    'products' as table_name,
    COUNT(*) as actual_count,
    4 as expected_count,
    CASE WHEN COUNT(*) = 4 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.products
UNION ALL
SELECT
    'website_sessions',
    COUNT(*),
    472871,
    CASE WHEN COUNT(*) = 472871 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_sessions
UNION ALL
SELECT
    'website_pageviews',
    COUNT(*),
    1188124,
    CASE WHEN COUNT(*) = 1188124 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_pageviews
UNION ALL
SELECT
    'orders',
    COUNT(*),
    32313,
    CASE WHEN COUNT(*) = 32313 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.orders
UNION ALL
SELECT
    'order_items',
    COUNT(*),
    40025,
    CASE WHEN COUNT(*) = 40025 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_items
UNION ALL
SELECT
    'order_item_refunds',
    COUNT(*),
    1731,
    CASE WHEN COUNT(*) = 1731 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_item_refunds;

\echo ''

-- ----------------------------------------------------------------------------
-- 2. PRIMARY KEY INTEGRITY CHECKS
-- ----------------------------------------------------------------------------
\echo '2. PRIMARY KEY INTEGRITY CHECKS'
\echo '-----------------------------------'
\echo ''
\echo '2a. NULL Values in Primary Keys'

SELECT
    'products' as table_name,
    'product_id' as pk_column,
    COUNT(*) FILTER (WHERE product_id IS NULL) as null_count,
    CASE WHEN COUNT(*) FILTER (WHERE product_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.products
UNION ALL
SELECT
    'website_sessions',
    'website_session_id',
    COUNT(*) FILTER (WHERE website_session_id IS NULL),
    CASE WHEN COUNT(*) FILTER (WHERE website_session_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_sessions
UNION ALL
SELECT
    'website_pageviews',
    'website_pageview_id',
    COUNT(*) FILTER (WHERE website_pageview_id IS NULL),
    CASE WHEN COUNT(*) FILTER (WHERE website_pageview_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_pageviews
UNION ALL
SELECT
    'orders',
    'order_id',
    COUNT(*) FILTER (WHERE order_id IS NULL),
    CASE WHEN COUNT(*) FILTER (WHERE order_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.orders
UNION ALL
SELECT
    'order_items',
    'order_item_id',
    COUNT(*) FILTER (WHERE order_item_id IS NULL),
    CASE WHEN COUNT(*) FILTER (WHERE order_item_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_items
UNION ALL
SELECT
    'order_item_refunds',
    'order_item_refund_id',
    COUNT(*) FILTER (WHERE order_item_refund_id IS NULL),
    CASE WHEN COUNT(*) FILTER (WHERE order_item_refund_id IS NULL) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_item_refunds;

\echo ''
\echo '2b. Duplicate Primary Keys'

SELECT
    'products' as table_name,
    'product_id' as pk_column,
    COUNT(*) - COUNT(DISTINCT product_id) as duplicate_count,
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.products
UNION ALL
SELECT
    'website_sessions',
    'website_session_id',
    COUNT(*) - COUNT(DISTINCT website_session_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT website_session_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_sessions
UNION ALL
SELECT
    'website_pageviews',
    'website_pageview_id',
    COUNT(*) - COUNT(DISTINCT website_pageview_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT website_pageview_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.website_pageviews
UNION ALL
SELECT
    'orders',
    'order_id',
    COUNT(*) - COUNT(DISTINCT order_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.orders
UNION ALL
SELECT
    'order_items',
    'order_item_id',
    COUNT(*) - COUNT(DISTINCT order_item_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_item_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_items
UNION ALL
SELECT
    'order_item_refunds',
    'order_item_refund_id',
    COUNT(*) - COUNT(DISTINCT order_item_refund_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_item_refund_id) THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_item_refunds;

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
    max_date::date - min_date::date as days_span,
    CASE
        WHEN min_date >= '2012-03-19' AND max_date <= '2015-04-30' THEN '✓ PASS'
        ELSE '⚠ WARNING'
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
-- 4. NOT NULL COLUMN VALIDATION
-- ----------------------------------------------------------------------------
\echo '4. NOT NULL COLUMN VALIDATION'
\echo '-----------------------------------'

WITH null_checks AS (
    SELECT 'website_sessions' as table_name, 'user_id' as column_name, COUNT(*) FILTER (WHERE user_id IS NULL) as null_count FROM raw.website_sessions
    UNION ALL SELECT 'website_sessions', 'device_type', COUNT(*) FILTER (WHERE device_type IS NULL) FROM raw.website_sessions
    UNION ALL SELECT 'website_sessions', 'is_repeat_session', COUNT(*) FILTER (WHERE is_repeat_session IS NULL) FROM raw.website_sessions
    UNION ALL SELECT 'website_pageviews', 'website_session_id', COUNT(*) FILTER (WHERE website_session_id IS NULL) FROM raw.website_pageviews
    UNION ALL SELECT 'website_pageviews', 'pageview_url', COUNT(*) FILTER (WHERE pageview_url IS NULL) FROM raw.website_pageviews
    UNION ALL SELECT 'orders', 'website_session_id', COUNT(*) FILTER (WHERE website_session_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'user_id', COUNT(*) FILTER (WHERE user_id IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'price_usd', COUNT(*) FILTER (WHERE price_usd IS NULL) FROM raw.orders
    UNION ALL SELECT 'orders', 'cogs_usd', COUNT(*) FILTER (WHERE cogs_usd IS NULL) FROM raw.orders
    UNION ALL SELECT 'order_items', 'order_id', COUNT(*) FILTER (WHERE order_id IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_items', 'product_id', COUNT(*) FILTER (WHERE product_id IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_items', 'price_usd', COUNT(*) FILTER (WHERE price_usd IS NULL) FROM raw.order_items
    UNION ALL SELECT 'order_item_refunds', 'order_id', COUNT(*) FILTER (WHERE order_id IS NULL) FROM raw.order_item_refunds
    UNION ALL SELECT 'order_item_refunds', 'order_item_id', COUNT(*) FILTER (WHERE order_item_id IS NULL) FROM raw.order_item_refunds
    UNION ALL SELECT 'order_item_refunds', 'refund_amount_usd', COUNT(*) FILTER (WHERE refund_amount_usd IS NULL) FROM raw.order_item_refunds
)
SELECT
    table_name,
    column_name,
    null_count,
    CASE WHEN null_count = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM null_checks
ORDER BY table_name, column_name;

\echo ''

-- ----------------------------------------------------------------------------
-- 5. REFERENTIAL INTEGRITY CHECKS
-- ----------------------------------------------------------------------------
\echo '5. REFERENTIAL INTEGRITY CHECKS'
\echo '-----------------------------------'
\echo ''
\echo '5a. Orders → Website Sessions (all orders have valid session IDs)'

SELECT
    COUNT(*) as total_orders,
    COUNT(CASE WHEN s.website_session_id IS NULL THEN 1 END) as orphaned_orders,
    CASE WHEN COUNT(CASE WHEN s.website_session_id IS NULL THEN 1 END) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.orders o
LEFT JOIN raw.website_sessions s ON o.website_session_id = s.website_session_id;

\echo ''
\echo '5b. Order Items → Orders (all items have valid order IDs)'

SELECT
    COUNT(*) as total_items,
    COUNT(CASE WHEN o.order_id IS NULL THEN 1 END) as orphaned_items,
    CASE WHEN COUNT(CASE WHEN o.order_id IS NULL THEN 1 END) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.order_items oi
LEFT JOIN raw.orders o ON oi.order_id = o.order_id;

\echo ''
\echo '5c. Order Item Refunds → Order Items (all refunds have valid order item IDs)'

SELECT
    COUNT(*) as total_refunds,
    COUNT(CASE WHEN oi.order_item_id IS NULL THEN 1 END) as orphaned_refunds,
    CASE WHEN COUNT(CASE WHEN oi.order_item_id IS NULL THEN 1 END) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.order_item_refunds r
LEFT JOIN raw.order_items oi ON r.order_item_id = oi.order_item_id;

\echo ''
\echo '5d. Pageviews → Sessions (all pageviews have valid session IDs)'

SELECT
    COUNT(*) as total_pageviews,
    COUNT(CASE WHEN s.website_session_id IS NULL THEN 1 END) as orphaned_pageviews,
    CASE WHEN COUNT(CASE WHEN s.website_session_id IS NULL THEN 1 END) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.website_pageviews pv
LEFT JOIN raw.website_sessions s ON pv.website_session_id = s.website_session_id;

\echo ''

-- ----------------------------------------------------------------------------
-- 6. BUSINESS LOGIC VALIDATION
-- ----------------------------------------------------------------------------
\echo '6. BUSINESS LOGIC VALIDATION'
\echo '-----------------------------------'
\echo ''
\echo '6a. Price Validation (prices > 0)'

SELECT
    'orders' as table_name,
    COUNT(*) FILTER (WHERE price_usd <= 0) as invalid_prices,
    CASE WHEN COUNT(*) FILTER (WHERE price_usd <= 0) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.orders
UNION ALL
SELECT
    'order_items',
    COUNT(*) FILTER (WHERE price_usd <= 0),
    CASE WHEN COUNT(*) FILTER (WHERE price_usd <= 0) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM raw.order_items;

\echo ''
\echo '6b. COGS Validation (COGS > 0 and <= price)'

SELECT
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE cogs_usd <= 0) as invalid_cogs_zero,
    COUNT(*) FILTER (WHERE cogs_usd > price_usd) as invalid_cogs_exceeds_price,
    CASE
        WHEN COUNT(*) FILTER (WHERE cogs_usd <= 0 OR cogs_usd > price_usd) = 0
        THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM raw.orders;

\echo ''
\echo '6c. Refund Amount Validation (refund amount > 0)'

SELECT
    COUNT(*) as total_refunds,
    COUNT(*) FILTER (WHERE refund_amount_usd <= 0) as invalid_refunds,
    CASE WHEN COUNT(*) FILTER (WHERE refund_amount_usd <= 0) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM raw.order_item_refunds;

\echo ''

-- ----------------------------------------------------------------------------
-- 7. DATA COMPLETENESS SUMMARY
-- ----------------------------------------------------------------------------
\echo '7. DATA COMPLETENESS SUMMARY'
\echo '-----------------------------------'

SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size('raw.' || table_name)) as size,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'raw' AND table_name = t.table_name) as columns,
    (xpath('/row/c/text()', query_to_xml(format('SELECT COUNT(*) as c FROM raw.%I', table_name), false, true, '')))[1]::text::int AS rows
FROM information_schema.tables t
WHERE table_schema = 'raw'
ORDER BY table_name;

\echo ''

-- ----------------------------------------------------------------------------
-- VALIDATION SUMMARY
-- ----------------------------------------------------------------------------
\echo '============================================================================'
\echo 'VALIDATION COMPLETE'
\echo '============================================================================'
\echo ''
\echo 'All validation checks completed. Review results above for any failures.'
\echo 'Legend:'
\echo '  ✓ PASS    - Check passed successfully'
\echo '  ✗ FAIL    - Check failed (requires attention)'
\echo '  ⚠ WARNING - Check passed with warnings'
\echo ''
\echo '============================================================================'
