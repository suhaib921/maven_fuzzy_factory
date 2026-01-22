# Maven Fuzzy Factory - Project Structure

This document outlines the complete directory structure for the data engineering pipeline.

## Directory Tree

```
maven_fuzzy_factory/
│
├── README.md                          # Project overview and setup instructions
├── requirements.txt                   # Python dependencies
├── .gitignore                        # Git ignore patterns
├── .env                              # Environment variables (DO NOT COMMIT)
│
├── data/                             # Raw data files
│   ├── raw/                          # Original CSV files
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── order_item_refunds.csv
│   │   ├── products.csv
│   │   ├── website_sessions.csv
│   │   └── website_pageviews.csv
│   └── processed/                    # Processed/cleaned data (optional)
│
├── sql/                              # Raw SQL scripts
│   ├── ddl/                          # Data Definition Language
│   │   ├── 01_create_schemas.sql
│   │   ├── 02_create_raw_tables.sql
│   │   └── 03_create_indexes.sql
│   ├── data_quality/                 # Data quality check queries
│   │   ├── row_count_validation.sql
│   │   ├── referential_integrity.sql
│   │   └── business_logic_checks.sql
│   └── analysis/                     # Ad-hoc analysis queries
│       └── exploratory_queries.sql
│
├── scripts/                          # Python scripts
│   ├── __init__.py
│   ├── load_raw_data.py             # CSV to PostgreSQL ingestion
│   ├── validate_data.py             # Data validation scripts
│   └── utils/
│       ├── __init__.py
│       ├── db_connection.py         # Database connection utilities
│       └── logger.py                # Logging configuration
│
├── dbt/                              # dbt project
│   └── maven_fuzzy_factory/          # dbt project root
│       ├── dbt_project.yml           # dbt project configuration
│       ├── profiles.yml              # Database connection profiles
│       ├── packages.yml              # dbt packages
│       ├── macros/                   # Custom SQL macros
│       │   ├── generate_schema_name.sql
│       │   └── custom_tests.sql
│       ├── models/                   # dbt models
│       │   ├── staging/              # Staging layer
│       │   │   ├── sources.yml       # Source definitions
│       │   │   ├── stg_sessions.sql
│       │   │   ├── stg_pageviews.sql
│       │   │   ├── stg_orders.sql
│       │   │   ├── stg_order_items.sql
│       │   │   ├── stg_refunds.sql
│       │   │   └── stg_products.sql
│       │   ├── mart/                 # Dimensional model (mart layer)
│       │   │   ├── dimensions/       # Dimension tables
│       │   │   │   ├── dim_date.sql
│       │   │   │   ├── dim_channel.sql
│       │   │   │   ├── dim_device.sql
│       │   │   │   ├── dim_product.sql
│       │   │   │   └── dim_page.sql
│       │   │   └── facts/            # Fact tables
│       │   │       ├── fact_sessions.sql
│       │   │       ├── fact_pageviews.sql
│       │   │       ├── fact_orders.sql
│       │   │       ├── fact_order_items.sql
│       │   │       └── fact_refunds.sql
│       │   ├── aggregate/            # Pre-aggregated tables
│       │   │   ├── agg_daily_traffic.sql
│       │   │   ├── agg_channel_performance.sql
│       │   │   ├── agg_product_performance.sql
│       │   │   └── agg_funnel_metrics.sql
│       │   └── schema.yml            # Tests and documentation
│       ├── tests/                    # Custom dbt tests
│       │   ├── assert_order_totals_match.sql
│       │   ├── assert_primary_items_count.sql
│       │   └── assert_conversion_rate_bounds.sql
│       ├── snapshots/                # SCD Type 2 snapshots (if needed)
│       └── seeds/                    # Static lookup data
│
├── airflow/                          # Airflow orchestration
│   ├── dags/                         # Airflow DAGs
│   │   ├── maven_fuzzy_factory_pipeline.py
│   │   └── config/
│   │       └── dag_config.yaml
│   ├── plugins/                      # Custom Airflow plugins
│   ├── logs/                         # Airflow logs (gitignored)
│   └── airflow.cfg                   # Airflow configuration
│
├── metabase/                         # Metabase configurations
│   ├── dashboards/                   # Dashboard exports (JSON)
│   │   ├── executive_summary.json
│   │   ├── channel_performance.json
│   │   ├── conversion_funnel.json
│   │   └── product_analysis.json
│   └── queries/                      # Saved queries
│
├── docs/                             # Documentation
│   ├── architecture/
│   │   ├── erd.png                   # Entity Relationship Diagram
│   │   ├── data_flow_diagram.png
│   │   └── architecture_overview.md
│   ├── data_dictionary/
│   │   ├── raw_layer.md
│   │   ├── staging_layer.md
│   │   ├── mart_layer.md
│   │   └── aggregate_layer.md
│   ├── guides/
│   │   ├── setup_guide.md
│   │   ├── development_guide.md
│   │   └── deployment_guide.md
│   └── decisions/
│       └── architecture_decisions.md
│
├── tests/                            # Python unit tests
│   ├── __init__.py
│   ├── test_data_loading.py
│   └── test_transformations.py
│
├── notebooks/                        # Jupyter notebooks for exploration
│   ├── 01_data_exploration.ipynb
│   ├── 02_funnel_analysis.ipynb
│   └── 03_cohort_analysis.ipynb
│
└── logs/                             # Application logs (gitignored)
    ├── data_loading.log
    └── pipeline_execution.log
```

## Key Files Description

### Root Level
- **README.md**: Project overview, setup instructions, and usage guide
- **requirements.txt**: All Python package dependencies
- **.gitignore**: Patterns for files to exclude from Git (logs, credentials, __pycache__, etc.)
- **.env**: Environment variables (database credentials, API keys) - NEVER commit this
- **PROJECT_TRACKER.md**: Ongoing project progress tracker
- **Project_overview.txt**: Detailed project requirements document

### data/
Contains all raw and processed data files. Raw CSVs should be copied here from the Maven+Fuzzy+Factory directory.

### sql/
Raw SQL scripts organized by purpose:
- **ddl/**: Database schema creation scripts
- **data_quality/**: Validation queries
- **analysis/**: Ad-hoc exploration queries

### scripts/
Python scripts for data loading and utilities:
- **load_raw_data.py**: Main script to ingest CSVs into PostgreSQL
- **validate_data.py**: Run data quality checks
- **utils/**: Helper modules for database connections and logging

### dbt/
Complete dbt project with layered transformation models:
- **staging/**: Clean and type-cast raw data
- **mart/dimensions/**: Dimension tables (date, channel, device, product, page)
- **mart/facts/**: Fact tables (sessions, pageviews, orders, order_items, refunds)
- **aggregate/**: Pre-computed metrics for dashboards
- **tests/**: Custom data quality tests
- **macros/**: Reusable SQL code snippets

### airflow/
Orchestration layer:
- **dags/**: Pipeline DAG definitions
- **plugins/**: Custom operators or sensors
- **logs/**: Execution logs (auto-generated)

### metabase/
BI tool configurations and dashboard exports

### docs/
Comprehensive documentation:
- **architecture/**: Diagrams and architectural docs
- **data_dictionary/**: Table and column definitions
- **guides/**: Setup, development, and deployment instructions
- **decisions/**: Record of technical decisions made

### tests/
Python unit tests for validation logic

### notebooks/
Jupyter notebooks for exploratory data analysis

## File Naming Conventions

### SQL Files
- Prefix with numbers for execution order: `01_`, `02_`, etc.
- Use snake_case: `create_raw_tables.sql`
- Be descriptive: `assert_order_totals_match.sql`

### dbt Models
- Prefix staging models with `stg_`: `stg_sessions.sql`
- Prefix dimensions with `dim_`: `dim_date.sql`
- Prefix facts with `fact_`: `fact_orders.sql`
- Prefix aggregates with `agg_`: `agg_daily_traffic.sql`

### Python Files
- Use snake_case: `load_raw_data.py`
- Test files prefix with `test_`: `test_data_loading.py`

## Git Strategy

### Branches
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches (e.g., `feature/dim-tables`)
- `bugfix/*`: Bug fix branches

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** feat, fix, docs, style, refactor, test, chore

**Example:**
```
feat(dbt): add dim_channel dimension table

- Parse UTM parameters
- Handle NULL values for direct traffic
- Add is_paid_traffic flag
- Include dbt tests for uniqueness

Closes #12
```

## .gitignore Patterns

```
# Python
__pycache__/
*.py[cod]
*$py.class
venv/
env/
.env

# dbt
dbt/target/
dbt/dbt_packages/
dbt/logs/

# Airflow
airflow/logs/
airflow/*.db
airflow/*.pid

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db

# Data (don't commit large files)
data/raw/*.csv
data/processed/*.parquet

# Credentials
*.pem
*.key
secrets/
```

## Environment Variables (.env)

```bash
# PostgreSQL Connection
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=maven_fuzzy_factory
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password

# Airflow
AIRFLOW_HOME=/path/to/airflow
AIRFLOW__CORE__DAGS_FOLDER=/path/to/dags
AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://user:pass@localhost/airflow

# dbt
DBT_PROFILES_DIR=/path/to/dbt

# Metabase
METABASE_PORT=3000
```

## Next Steps

1. Create the directory structure: `mkdir -p {data,sql,scripts,dbt,airflow,metabase,docs,tests,notebooks,logs}`
2. Copy CSV files to `data/raw/`
3. Create `.gitignore` file
4. Initialize Git repository: `git init`
5. Create `.env` file with database credentials
6. Install Python dependencies: `pip install -r requirements.txt`
7. Begin Phase 1 tasks from PROJECT_TRACKER.md

---

**Note:** This structure follows industry best practices and supports:
- Clear separation of concerns
- Easy navigation
- Version control
- Scalability
- Team collaboration
- CI/CD integration
