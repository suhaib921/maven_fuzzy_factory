-- ============================================================================
-- Maven Fuzzy Factory - Database and Schema Setup
-- ============================================================================
-- Description: Creates the main database and schema structure for the
--              data engineering pipeline
-- Author: suhaib921 (Suhaib abdi)
-- Created: 2026-01-20
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CREATE DATABASE
-- ----------------------------------------------------------------------------
-- Note: This must be run as a superuser connected to the 'postgres' database
-- Command: psql -U suhkth -d postgres -f 01_create_database_and_schemas.sql

-- CREATE DATABASE maven_fuzzy_factory;
-- Note: Commented out because you cannot create a database from within a
--       database connection. Run this separately:
--       psql -U suhkth -d postgres -c "CREATE DATABASE maven_fuzzy_factory;"

-- ----------------------------------------------------------------------------
-- 2. CONNECT TO DATABASE
-- ----------------------------------------------------------------------------
-- After creating the database, connect to it:
-- \c maven_fuzzy_factory

-- ----------------------------------------------------------------------------
-- 3. CREATE SCHEMAS
-- ----------------------------------------------------------------------------
-- The pipeline uses a 4-layer architecture:
--   - raw:       Raw data loaded directly from source files
--   - staging:   Cleaned and typed data (dbt staging models)
--   - mart:      Business-ready dimensional model (fact & dimension tables)
--   - aggregate: Pre-aggregated tables for dashboards and reporting

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE SCHEMA IF NOT EXISTS aggregate;

-- ----------------------------------------------------------------------------
-- 4. VERIFY SCHEMA CREATION
-- ----------------------------------------------------------------------------
-- Query to verify all schemas were created:
-- SELECT schema_name
-- FROM information_schema.schemata
-- WHERE schema_name IN ('raw', 'staging', 'mart', 'aggregate')
-- ORDER BY schema_name;

-- ----------------------------------------------------------------------------
-- 5. GRANT PERMISSIONS (Optional - if using multiple users)
-- ----------------------------------------------------------------------------
-- If you need to grant permissions to other users:
-- GRANT USAGE ON SCHEMA raw TO <username>;
-- GRANT USAGE ON SCHEMA staging TO <username>;
-- GRANT USAGE ON SCHEMA mart TO <username>;
-- GRANT USAGE ON SCHEMA aggregate TO <username>;

-- GRANT SELECT ON ALL TABLES IN SCHEMA raw TO <username>;
-- GRANT SELECT ON ALL TABLES IN SCHEMA staging TO <username>;
-- GRANT SELECT ON ALL TABLES IN SCHEMA mart TO <username>;
-- GRANT SELECT ON ALL TABLES IN SCHEMA aggregate TO <username>;

-- ----------------------------------------------------------------------------
-- SETUP COMPLETE
-- ----------------------------------------------------------------------------
-- ✓ Database: maven_fuzzy_factory
-- ✓ Schemas: raw, staging, mart, aggregate
--
-- Next Steps:
-- 1. Create raw layer tables (02_create_raw_tables.sql)
-- 2. Load CSV data into raw tables
-- 3. Set up dbt for transformations
-- ============================================================================
