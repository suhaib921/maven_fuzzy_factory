# Maven Fuzzy Factory - E-Commerce Analytics Data Warehouse

A comprehensive data engineering pipeline for e-commerce analytics, featuring a modern data stack with PostgreSQL, dbt, Apache Airflow, and Metabase.

![Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![Pipeline](https://img.shields.io/badge/Pipeline-Automated-blue)
![Tests](https://img.shields.io/badge/Tests-266%20Passing-success)
![Progress](https://img.shields.io/badge/Progress-97%25-brightgreen)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Data Model](#data-model)
- [Quick Start](#quick-start)
- [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
- [Testing](#testing)
- [Performance Metrics](#performance-metrics)
- [Dashboards](#dashboards)
- [Project Structure](#project-structure)
- [Maintenance](#maintenance)
- [License](#license)

---

## 🎯 Project Overview

Maven Fuzzy Factory is a data engineering project that implements a complete analytics data warehouse for an e-commerce toy store. The project demonstrates best practices in:

- **Data Warehouse Design:** 4-layer architecture (Raw → Staging → Mart → Aggregate)
- **Data Modeling:** Star schema with 5 dimensions and 5 fact tables
- **Data Quality:** 266 automated tests with 100% pass rate
- **Orchestration:** Automated pipeline execution via Apache Airflow
- **Business Intelligence:** 6 comprehensive dashboards with 28 visualizations

### Key Metrics

- **Data Volume:** 1.7 million rows across 24 tables
- **Date Range:** March 2012 - March 2015 (3 years)
- **Business Metrics:** 472K sessions, 32K orders, $1.94M revenue
- **Pipeline Runtime:** 7-8 minutes end-to-end
- **Data Quality:** 100% test pass rate (266/266 tests)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                             │
│               CSV Files (6 tables, 1.7M rows)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      LAYER 1: RAW                                │
│          PostgreSQL Tables (raw schema)                          │
│   • website_sessions     • website_pageviews                     │
│   • orders              • order_items                            │
│   • order_item_refunds  • products                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   LAYER 2: STAGING (dbt)                         │
│              Views with Type Casting & Cleanup                   │
│   • stg_website_sessions    • stg_website_pageviews             │
│   • stg_orders              • stg_order_items                    │
│   • stg_order_item_refunds  • stg_products                       │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                 LAYER 3: MART (dbt Star Schema)                  │
│                                                                   │
│  DIMENSIONS (5 tables)      │      FACTS (5 tables)              │
│  • dim_date                 │      • fact_sessions               │
│  • dim_channel              │      • fact_pageviews              │
│  • dim_device               │      • fact_orders                 │
│  • dim_product              │      • fact_order_items            │
│  • dim_page                 │      • fact_refunds                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                LAYER 4: AGGREGATE (dbt)                          │
│             Pre-computed Metrics for Dashboards                  │
│   • agg_daily_traffic      • agg_channel_performance             │
│   • agg_product_performance • agg_funnel_metrics                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ORCHESTRATION LAYER                            │
│                   Apache Airflow                                 │
│   • DAG: maven_fuzzy_factory_pipeline                            │
│   • Schedule: Daily at 2 AM UTC                                  │
│   • 13 tasks, ~7-8 min runtime                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    VISUALIZATION LAYER                           │
│                       Metabase                                   │
│   • 6 Dashboards                                                 │
│   • 28 Visualizations                                            │
│   • < 2 second query time                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Database** | PostgreSQL | 16.11 | Data warehouse |
| **ETL/ELT** | dbt (data build tool) | 1.11.2 | Data transformations |
| **Orchestration** | Apache Airflow | 3.1.6 | Pipeline automation |
| **BI Tool** | Metabase | 0.51.5 | Dashboards & analytics |
| **Language** | Python | 3.12.3 | Data ingestion scripts |
| **Runtime** | Java | 21.0.9 | Metabase server |

### Python Packages
- **psycopg2-binary** 2.9.11 - PostgreSQL adapter
- **pandas** 2.3.3 - Data manipulation
- **dbt-postgres** 1.10.0 - dbt PostgreSQL adapter
- **apache-airflow** 3.1.6 - Workflow orchestration

---

## 📊 Data Model

### Star Schema Design

**5 Dimension Tables:**
1. **dim_date** (1,461 rows) - Calendar dimension with 27 attributes
2. **dim_channel** (7 rows) - Marketing channels (Google, Bing, Social, Direct)
3. **dim_device** (2 rows) - Device types (Desktop, Mobile)
4. **dim_product** (4 rows) - Product catalog (Mr. Fuzzy, Love Bear, etc.)
5. **dim_page** (16 rows) - Website pages with types and categories

**5 Fact Tables:**
1. **fact_sessions** (472,871 rows) - Web session metrics with funnel flags
2. **fact_pageviews** (1,188,124 rows) - Page-level clickstream data
3. **fact_orders** (32,313 rows) - Order transactions with revenue metrics
4. **fact_order_items** (40,025 rows) - Line item details with margins
5. **fact_refunds** (1,731 rows) - Refund transactions with timing metrics

**4 Aggregate Tables:**
1. **agg_daily_traffic** - Daily session and order metrics
2. **agg_channel_performance** - Channel-level KPIs
3. **agg_product_performance** - Product revenue and margins
4. **agg_funnel_metrics** - Conversion funnel metrics

---

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 14+ installed and running
- Python 3.9+ installed
- Java 11+ installed (for Metabase)
- 5GB free disk space

### Installation (5 minutes)

```bash
# 1. Clone/Navigate to project directory
cd maven_fuzzy_factory

# 2. Create Python virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Create PostgreSQL database
createdb maven_fuzzy_factory
psql -d maven_fuzzy_factory -f sql/01_create_database_and_schemas.sql

# 5. Load raw data
python scripts/load_raw_data.py

# 6. Run dbt transformations
cd dbt/maven_fuzzy_factory
dbt run
dbt test

# 7. Start Airflow (optional)
export AIRFLOW_HOME="$(pwd)/../../airflow"
airflow db init
airflow webserver -p 8080 &
airflow scheduler &

# 8. Start Metabase (optional)
cd ../../metabase
java -jar metabase.jar
```

**Access Points:**
- **Airflow:** http://localhost:8080 (admin/admin123)
- **Metabase:** http://localhost:3000 (admin@example.com/admin123)
- **PostgreSQL:** localhost:5432/maven_fuzzy_factory (suhkth/maven123)

---

## 📖 Setup Instructions

### 1. Database Setup

```bash
# Create database and schemas
psql -U postgres << EOF
CREATE DATABASE maven_fuzzy_factory;
\c maven_fuzzy_factory
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA mart;
CREATE SCHEMA aggregate;
EOF

# Create raw tables
psql -d maven_fuzzy_factory -f sql/02_create_raw_tables.sql
```

### 2. Data Ingestion

```bash
# Load CSV files into raw schema
python scripts/load_raw_data.py

# Validate data loaded correctly
psql -d maven_fuzzy_factory -f sql/03_validate_raw_data.sql
```

Expected row counts:
- website_sessions: 472,871
- website_pageviews: 1,188,124
- orders: 32,313
- order_items: 40,025
- order_item_refunds: 1,731
- products: 4

### 3. dbt Configuration

```bash
# Configure dbt profile
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << EOF
maven_fuzzy_factory:
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: suhkth
      password: maven123
      dbname: maven_fuzzy_factory
      schema: staging
      threads: 4
  target: dev
EOF

# Test connection
cd dbt/maven_fuzzy_factory
dbt debug

# Run transformations
dbt run
dbt test
```

### 4. Airflow Setup

```bash
# Initialize Airflow database
export AIRFLOW_HOME="$(pwd)/airflow"
airflow db init

# Create admin user
airflow users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com \
  --password admin123

# Add PostgreSQL connection
airflow connections add 'postgres_maven' \
  --conn-type 'postgres' \
  --conn-host 'localhost' \
  --conn-schema 'maven_fuzzy_factory' \
  --conn-login 'suhkth' \
  --conn-password 'maven123' \
  --conn-port 5432

# Start services
airflow webserver -p 8080 &
airflow scheduler &
```

### 5. Metabase Setup

```bash
# Download Metabase (if not already downloaded)
cd metabase
curl -L -o metabase.jar https://downloads.metabase.com/latest/metabase.jar

# Start Metabase
java -jar metabase.jar

# Access http://localhost:3000 and complete setup wizard:
# - Create admin user: admin@example.com / admin123
# - Add database: PostgreSQL, localhost:5432, maven_fuzzy_factory
# - Schema filter: mart
```

---

## 💡 Usage Guide

### Running the Pipeline Manually

**Option 1: dbt Only**
```bash
cd dbt/maven_fuzzy_factory
dbt run          # Build all models
dbt test         # Run all tests
dbt docs generate  # Generate documentation
dbt docs serve   # View docs at http://localhost:8080
```

**Option 2: Airflow DAG**
```bash
# Trigger DAG manually
airflow dags trigger maven_fuzzy_factory_pipeline

# Monitor execution
airflow dags list-runs -d maven_fuzzy_factory_pipeline

# View logs
tail -f airflow/logs/scheduler.log
```

### Querying the Data

```sql
-- Connect to database
psql -d maven_fuzzy_factory -U suhkth

-- Example: Monthly revenue trend
SELECT
    d.year || '-' || LPAD(d.month_of_year::text, 2, '0') as month,
    COUNT(DISTINCT f.order_id) as orders,
    ROUND(SUM(f.gross_revenue_usd), 2) as revenue
FROM mart.fact_orders f
JOIN mart.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_of_year
ORDER BY d.year, d.month_of_year;
```

### Accessing Dashboards

1. **Open Metabase:** http://localhost:3000
2. **Login:** admin@example.com / admin123
3. **Navigate to dashboards:**
   - Executive Summary
   - Channel Performance
   - Conversion Funnel
   - Product Performance
   - Landing Page A/B Tests
   - Refund Analysis

---

## 🧪 Testing

### Test Coverage

| Layer | Tests | Status |
|-------|-------|--------|
| **Source (Raw)** | 48 tests | ✅ 100% passing |
| **Staging** | 38 tests | ✅ 100% passing |
| **Dimensions** | 42 tests | ✅ 100% passing |
| **Facts** | 90 tests | ✅ 100% passing |
| **Aggregates** | 25 tests | ✅ 100% passing |
| **Custom Business Logic** | 13 tests | ✅ 100% passing |
| **Generic Tests** | 10 tests | ✅ 100% passing |
| **TOTAL** | **266 tests** | **✅ 100% passing** |

### Running Tests

```bash
# Run all tests
dbt test

# Run specific test types
dbt test --select staging
dbt test --select test_type:unique
dbt test --select test_type:singular

# Run tests with detailed output
dbt test --select staging --store-failures
```

### Test Types

1. **Unique Tests** - Ensure primary keys are unique
2. **Not Null Tests** - Validate required fields
3. **Relationship Tests** - Check foreign key integrity
4. **Accepted Values Tests** - Validate enum fields
5. **Custom Business Logic Tests** - Verify business rules
6. **Data Consistency Tests** - Cross-table validations

---

## ⚡ Performance Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Raw data load | < 2 min | 62 sec | ✅ Exceeds |
| dbt full refresh | < 5 min | 41 sec | ✅ Exceeds |
| dbt test execution | < 60 sec | 38 sec | ✅ Exceeds |
| Airflow pipeline | < 10 min | 7-8 min | ✅ Meets |
| Dashboard queries | < 5 sec | < 2 sec | ✅ Exceeds |
| Test pass rate | 100% | 100% | ✅ Perfect |

### Optimization Strategies

1. **Indexing:** Foreign keys indexed for fast joins
2. **Aggregates:** Pre-computed metrics for dashboards
3. **Partitioning:** Date-based partitioning for large fact tables (future)
4. **Materialization:** Facts as tables, staging as views
5. **Incremental Models:** Can be implemented for production (future)

---

## 📊 Dashboards

### 1. Executive Summary
**KPIs:** Sessions, Orders, Conversion Rate, Revenue, AOV, Margin
**Charts:** Traffic trend, Revenue trend, Conversion rate over time

### 2. Channel Performance
**Analysis:** Traffic by channel, Revenue by source, Brand vs Nonbrand
**Charts:** Channel breakdown, Performance trends, ROI metrics

### 3. Conversion Funnel
**Metrics:** Products reached, Cart reached, Billing reached, Orders
**Charts:** Funnel visualization, Drop-off analysis, Device comparison

### 4. Product Performance
**Analysis:** Revenue by product, Margin analysis, Cross-sell patterns
**Charts:** Product revenue share, Sales trends, Refund rates

### 5. Landing Page A/B Tests
**Comparison:** Home vs Lander versions, Conversion rates, Bounce rates
**Charts:** Performance comparison, Time series, Statistical significance

### 6. Refund Analysis
**Metrics:** Refund count, Refund amount, Days to refund, Refund rate
**Charts:** Refund trends, Product breakdown, Timing distribution

---

## 📁 Project Structure

```
maven_fuzzy_factory/
├── README.md                      # This file
├── PROJECT_TRACKER.md             # Detailed project progress
├── requirements.txt               # Python dependencies
├── .gitignore                     # Git ignore patterns
│
├── data/                          # Data files
│   └── raw/                       # Original CSV files (6 files)
│
├── sql/                           # SQL scripts
│   ├── 01_create_database_and_schemas.sql
│   ├── 02_create_raw_tables.sql
│   ├── 03_validate_raw_data.sql
│   └── 04_data_quality_checks.sql
│
├── scripts/                       # Python scripts
│   ├── load_raw_data.py          # Data ingestion script
│   └── validate_data.py          # Validation script
│
├── dbt/maven_fuzzy_factory/      # dbt project
│   ├── dbt_project.yml           # dbt configuration
│   ├── models/
│   │   ├── staging/              # Staging models (6 models)
│   │   ├── mart/
│   │   │   ├── dimensions/       # Dimension tables (5 models)
│   │   │   └── facts/            # Fact tables (5 models)
│   │   └── aggregate/            # Aggregate tables (4 models)
│   ├── tests/                    # Custom dbt tests (13 tests)
│   └── macros/                   # Custom macros
│
├── airflow/                      # Airflow orchestration
│   ├── dags/
│   │   └── maven_fuzzy_factory_pipeline.py
│   ├── logs/                     # Execution logs
│   └── airflow.cfg               # Airflow configuration
│
├── metabase/                     # Metabase BI tool
│   ├── metabase.jar              # Metabase application
│   ├── metabase.log              # Server logs
│   └── dashboard_queries.md      # All dashboard SQL queries
│
└── docs/                         # Documentation
    ├── erd_diagram.dbml          # Entity relationship diagram
    ├── data_dictionary.md        # Table and column definitions
    ├── architecture_diagram.md   # System architecture
    └── testing_results.md        # Test execution results
```

---

## 🔧 Maintenance

### Daily Operations

**Automated (via Airflow):**
- Pipeline runs daily at 2 AM UTC
- 13 tasks execute sequentially
- 266 tests validate data quality
- Email alerts on failures (configure in Airflow)

**Manual Monitoring:**
1. Check Airflow DAG status: http://localhost:8080
2. Verify test results: `dbt test`
3. Review dashboard metrics in Metabase
4. Monitor database size: `SELECT pg_size_pretty(pg_database_size('maven_fuzzy_factory'));`

### Troubleshooting

**Pipeline Failures:**
```bash
# Check Airflow logs
tail -f airflow/logs/scheduler.log

# Re-run failed DAG
airflow dags trigger maven_fuzzy_factory_pipeline

# Run specific dbt model
cd dbt/maven_fuzzy_factory
dbt run --select model_name
```

**Test Failures:**
```bash
# Run tests with failures stored
dbt test --store-failures

# Query failed test results
SELECT * FROM dbt_test_failures.unique_dim_date_date_key;
```

**Performance Issues:**
```bash
# Analyze query performance
EXPLAIN ANALYZE SELECT ...;

# Rebuild indexes
REINDEX DATABASE maven_fuzzy_factory;

# Vacuum and analyze
VACUUM ANALYZE;
```

---

## 📄 License

This project is created for educational purposes. Data is synthetic and provided by Maven Analytics.

---

## 🙏 Acknowledgments

- **Maven Analytics** for providing the dataset
- **dbt Labs** for the amazing transformation framework
- **Apache Airflow** community for orchestration tools
- **Metabase** for the open-source BI platform

---

**Project Status:** Production Ready ✅
**Last Updated:** 2026-01-22
**Maintained By:** Suhaib
**Completion:** 97% (30/31 tasks)

---

## 🎯 Quick Links

- [Project Tracker](PROJECT_TRACKER.md) - Detailed progress tracking
- [ERD Diagram](docs/erd_diagram.dbml) - Database schema visualization
- [Data Dictionary](docs/data_dictionary.md) - Table and column definitions
- [Dashboard Queries](metabase/dashboard_queries.md) - All SQL queries
- [Architecture](docs/architecture_diagram.md) - System design document

**Happy Analyzing! 📊**
