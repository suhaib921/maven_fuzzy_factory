-- ============================================================================
-- Maven Fuzzy Factory - Raw Layer Table Definitions
-- ============================================================================
-- Description: Creates all 6 raw data tables for CSV data ingestion
-- Author: suhaib921 (Suhaib abdi)
-- Created: 2026-01-20
-- Database: maven_fuzzy_factory
-- Schema: raw
-- ============================================================================
--
-- Table Summary:
--   1. raw.website_sessions      (~472,871 rows)
--   2. raw.website_pageviews     (~1,188,124 rows)
--   3. raw.orders                (~32,313 rows)
--   4. raw.order_items           (~40,025 rows)
--   5. raw.order_item_refunds    (~1,731 rows)
--   6. raw.products              (4 rows)
--
-- All tables include audit columns:
--   - _load_timestamp: When the data was loaded
--   - _source_file: Source CSV file name
-- ============================================================================

-- Connect to database
\c maven_fuzzy_factory

-- ----------------------------------------------------------------------------
-- 1. RAW.WEBSITE_SESSIONS
-- ----------------------------------------------------------------------------
-- Description: User website session data with UTM parameters and device info
-- Source: website_sessions.csv (~472,871 rows)
-- Primary Key: website_session_id

DROP TABLE IF EXISTS raw.website_sessions CASCADE;

CREATE TABLE raw.website_sessions (
    -- Primary Key
    website_session_id      INTEGER PRIMARY KEY,

    -- Timestamps
    created_at              TIMESTAMP NOT NULL,

    -- User Information
    user_id                 INTEGER NOT NULL,
    is_repeat_session       INTEGER NOT NULL,  -- 0 or 1 (boolean flag)

    -- UTM Parameters (Marketing Attribution)
    utm_source              VARCHAR(100),      -- Can be NULL (direct traffic)
    utm_campaign            VARCHAR(100),
    utm_content             VARCHAR(100),

    -- Device & Referrer
    device_type             VARCHAR(50) NOT NULL,  -- 'mobile' or 'desktop'
    http_referer            VARCHAR(500),

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

-- Create indexes for common queries
CREATE INDEX idx_website_sessions_created_at ON raw.website_sessions(created_at);
CREATE INDEX idx_website_sessions_user_id ON raw.website_sessions(user_id);
CREATE INDEX idx_website_sessions_utm_source ON raw.website_sessions(utm_source);
CREATE INDEX idx_website_sessions_device_type ON raw.website_sessions(device_type);

COMMENT ON TABLE raw.website_sessions IS 'Raw website session data including UTM parameters and device information';
COMMENT ON COLUMN raw.website_sessions._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.website_sessions._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- 2. RAW.WEBSITE_PAGEVIEWS
-- ----------------------------------------------------------------------------
-- Description: Individual page view events within website sessions
-- Source: website_pageviews.csv (~1,188,124 rows)
-- Primary Key: website_pageview_id
-- Foreign Key: website_session_id → raw.website_sessions

DROP TABLE IF EXISTS raw.website_pageviews CASCADE;

CREATE TABLE raw.website_pageviews (
    -- Primary Key
    website_pageview_id     INTEGER PRIMARY KEY,

    -- Timestamps
    created_at              TIMESTAMP NOT NULL,

    -- Foreign Keys
    website_session_id      INTEGER NOT NULL,

    -- Pageview Data
    pageview_url            VARCHAR(500) NOT NULL,

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

-- Create indexes for common queries
CREATE INDEX idx_website_pageviews_created_at ON raw.website_pageviews(created_at);
CREATE INDEX idx_website_pageviews_session_id ON raw.website_pageviews(website_session_id);
CREATE INDEX idx_website_pageviews_url ON raw.website_pageviews(pageview_url);

COMMENT ON TABLE raw.website_pageviews IS 'Raw pageview event data tracking user navigation through the website';
COMMENT ON COLUMN raw.website_pageviews._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.website_pageviews._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- 3. RAW.PRODUCTS
-- ----------------------------------------------------------------------------
-- Description: Product catalog (slowly changing dimension)
-- Source: products.csv (4 rows)
-- Primary Key: product_id

DROP TABLE IF EXISTS raw.products CASCADE;

CREATE TABLE raw.products (
    -- Primary Key
    product_id              INTEGER PRIMARY KEY,

    -- Product Launch Date
    created_at              TIMESTAMP NOT NULL,

    -- Product Information
    product_name            VARCHAR(200) NOT NULL,

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

COMMENT ON TABLE raw.products IS 'Raw product catalog data with product launch dates';
COMMENT ON COLUMN raw.products.created_at IS 'Product launch date';
COMMENT ON COLUMN raw.products._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.products._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- 4. RAW.ORDERS
-- ----------------------------------------------------------------------------
-- Description: Order header information
-- Source: orders.csv (~32,313 rows)
-- Primary Key: order_id
-- Foreign Keys: website_session_id, user_id, primary_product_id

DROP TABLE IF EXISTS raw.orders CASCADE;

CREATE TABLE raw.orders (
    -- Primary Key
    order_id                INTEGER PRIMARY KEY,

    -- Timestamps
    created_at              TIMESTAMP NOT NULL,

    -- Foreign Keys
    website_session_id      INTEGER NOT NULL,
    user_id                 INTEGER NOT NULL,
    primary_product_id      INTEGER NOT NULL,

    -- Order Details
    items_purchased         INTEGER NOT NULL,
    price_usd               DECIMAL(10, 2) NOT NULL,
    cogs_usd                DECIMAL(10, 2) NOT NULL,

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

-- Create indexes for common queries
CREATE INDEX idx_orders_created_at ON raw.orders(created_at);
CREATE INDEX idx_orders_session_id ON raw.orders(website_session_id);
CREATE INDEX idx_orders_user_id ON raw.orders(user_id);
CREATE INDEX idx_orders_product_id ON raw.orders(primary_product_id);

COMMENT ON TABLE raw.orders IS 'Raw order header data with pricing and product information';
COMMENT ON COLUMN raw.orders.primary_product_id IS 'Main product in the order (relevant for bundles)';
COMMENT ON COLUMN raw.orders.items_purchased IS 'Total number of items in the order';
COMMENT ON COLUMN raw.orders._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.orders._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- 5. RAW.ORDER_ITEMS
-- ----------------------------------------------------------------------------
-- Description: Individual line items within orders
-- Source: order_items.csv (~40,025 rows)
-- Primary Key: order_item_id
-- Foreign Keys: order_id, product_id

DROP TABLE IF EXISTS raw.order_items CASCADE;

CREATE TABLE raw.order_items (
    -- Primary Key
    order_item_id           INTEGER PRIMARY KEY,

    -- Timestamps
    created_at              TIMESTAMP NOT NULL,

    -- Foreign Keys
    order_id                INTEGER NOT NULL,
    product_id              INTEGER NOT NULL,

    -- Line Item Details
    is_primary_item         INTEGER NOT NULL,  -- 0 or 1 (boolean flag)
    price_usd               DECIMAL(10, 2) NOT NULL,
    cogs_usd                DECIMAL(10, 2) NOT NULL,

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

-- Create indexes for common queries
CREATE INDEX idx_order_items_created_at ON raw.order_items(created_at);
CREATE INDEX idx_order_items_order_id ON raw.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON raw.order_items(product_id);

COMMENT ON TABLE raw.order_items IS 'Raw order line item data with individual product pricing';
COMMENT ON COLUMN raw.order_items.is_primary_item IS 'Flag indicating if this is the primary item in the order';
COMMENT ON COLUMN raw.order_items._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.order_items._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- 6. RAW.ORDER_ITEM_REFUNDS
-- ----------------------------------------------------------------------------
-- Description: Refund transactions for order items
-- Source: order_item_refunds.csv (~1,731 rows)
-- Primary Key: order_item_refund_id
-- Foreign Keys: order_item_id, order_id

DROP TABLE IF EXISTS raw.order_item_refunds CASCADE;

CREATE TABLE raw.order_item_refunds (
    -- Primary Key
    order_item_refund_id    INTEGER PRIMARY KEY,

    -- Timestamps
    created_at              TIMESTAMP NOT NULL,

    -- Foreign Keys
    order_item_id           INTEGER NOT NULL,
    order_id                INTEGER NOT NULL,

    -- Refund Details
    refund_amount_usd       DECIMAL(10, 2) NOT NULL,

    -- Audit Columns
    _load_timestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _source_file            VARCHAR(255)
);

-- Create indexes for common queries
CREATE INDEX idx_order_item_refunds_created_at ON raw.order_item_refunds(created_at);
CREATE INDEX idx_order_item_refunds_order_item_id ON raw.order_item_refunds(order_item_id);
CREATE INDEX idx_order_item_refunds_order_id ON raw.order_item_refunds(order_id);

COMMENT ON TABLE raw.order_item_refunds IS 'Raw refund transaction data for order items';
COMMENT ON COLUMN raw.order_item_refunds._load_timestamp IS 'Timestamp when data was loaded into the database';
COMMENT ON COLUMN raw.order_item_refunds._source_file IS 'Source CSV filename';

-- ----------------------------------------------------------------------------
-- VERIFY TABLE CREATION
-- ----------------------------------------------------------------------------
-- Run this query to verify all tables were created:
-- SELECT table_name,
--        (SELECT COUNT(*) FROM information_schema.columns
--         WHERE table_schema = 'raw' AND table_name = t.table_name) as column_count
-- FROM information_schema.tables t
-- WHERE table_schema = 'raw'
-- ORDER BY table_name;

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
-- ✓ All 6 raw tables created with proper data types
-- ✓ Primary keys defined
-- ✓ Indexes created for common query patterns
-- ✓ Audit columns (_load_timestamp, _source_file) added to all tables
-- ✓ Table and column comments added for documentation
--
-- Next Steps:
-- 1. Load CSV data using Python ingestion script (Task 3.1)
-- 2. Validate row counts match expected values (Task 3.2)
-- 3. Run data quality checks (Task 3.3)
-- ============================================================================
