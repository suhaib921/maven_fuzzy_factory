# Maven Fuzzy Factory - E-Commerce Analytics Data Warehouse

A complete data engineering pipeline for e-commerce analytics, built using a modern data stack with PostgreSQL, dbt, Apache Airflow, and Metabase.

This project implements a full analytics data warehouse for an e-commerce toy store and demonstrates best practices in:
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
