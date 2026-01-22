"""
Maven Fuzzy Factory - Complete Data Pipeline DAG

This DAG orchestrates the full data transformation pipeline for the Maven Fuzzy Factory
e-commerce toy store analytics platform using dbt.

Pipeline Stages:
1. Staging Layer: Clean and standardize raw data
2. Dimension Tables: Build slowly changing dimensions
3. Fact Tables: Build transaction fact tables
4. Aggregate Layer: Build pre-aggregated tables for dashboard performance
5. Data Quality Tests: Run comprehensive test suite

Schedule: Daily at 2 AM UTC
Owner: Data Engineering Team
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator

# Default arguments for all tasks
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(minutes=30),
}

# DAG definition
dag = DAG(
    'maven_fuzzy_factory_pipeline',
    default_args=default_args,
    description='Complete dbt pipeline for Maven Fuzzy Factory analytics',
    schedule_interval='0 2 * * *',  # Daily at 2 AM UTC
    start_date=datetime(2026, 1, 22),
    catchup=False,
    max_active_runs=1,
    tags=['dbt', 'maven_fuzzy_factory', 'analytics'],
)

# Define dbt project path and commands
DBT_PROJECT_DIR = '/home/suhkth/Desktop/Toy Store E-Commerce Database/maven_fuzzy_factory/dbt/maven_fuzzy_factory'
DBT_VENV_PATH = '/home/suhkth/Desktop/Toy Store E-Commerce Database/maven_fuzzy_factory/venv/bin/activate'

def get_dbt_command(command):
    """Helper function to construct dbt commands with proper environment activation."""
    return f'cd "{DBT_PROJECT_DIR}" && source "{DBT_VENV_PATH}" && {command}'

# ============================================================================
# Task Definitions
# ============================================================================

# Start task (marker for pipeline start)
start = DummyOperator(
    task_id='start_pipeline',
    dag=dag,
)

# ============================================================================
# Layer 1: Staging Models
# ============================================================================

run_staging = BashOperator(
    task_id='run_staging_models',
    bash_command=get_dbt_command('dbt run --select staging'),
    dag=dag,
)

test_staging = BashOperator(
    task_id='test_staging_models',
    bash_command=get_dbt_command('dbt test --select staging'),
    dag=dag,
)

# ============================================================================
# Layer 2: Dimension Tables
# ============================================================================

run_dimensions = BashOperator(
    task_id='run_dimension_tables',
    bash_command=get_dbt_command('dbt run --select mart.dimensions'),
    dag=dag,
)

test_dimensions = BashOperator(
    task_id='test_dimension_tables',
    bash_command=get_dbt_command('dbt test --select mart.dimensions'),
    dag=dag,
)

# ============================================================================
# Layer 3: Fact Tables
# ============================================================================

run_facts = BashOperator(
    task_id='run_fact_tables',
    bash_command=get_dbt_command('dbt run --select mart.facts'),
    dag=dag,
)

test_facts = BashOperator(
    task_id='test_fact_tables',
    bash_command=get_dbt_command('dbt test --select mart.facts'),
    dag=dag,
)

# ============================================================================
# Layer 4: Aggregate Tables
# ============================================================================

run_aggregates = BashOperator(
    task_id='run_aggregate_tables',
    bash_command=get_dbt_command('dbt run --select aggregate'),
    dag=dag,
)

test_aggregates = BashOperator(
    task_id='test_aggregate_tables',
    bash_command=get_dbt_command('dbt test --select aggregate'),
    dag=dag,
)

# ============================================================================
# Data Quality: Custom Business Logic Tests
# ============================================================================

run_custom_tests = BashOperator(
    task_id='run_custom_business_tests',
    bash_command=get_dbt_command('dbt test --select test_type:singular'),
    dag=dag,
)

# ============================================================================
# Final Validation: Full Test Suite
# ============================================================================

run_full_test_suite = BashOperator(
    task_id='run_full_test_suite',
    bash_command=get_dbt_command('dbt test'),
    dag=dag,
)

# Generate dbt documentation
generate_docs = BashOperator(
    task_id='generate_dbt_docs',
    bash_command=get_dbt_command('dbt docs generate'),
    dag=dag,
)

# End task (marker for pipeline completion)
end = DummyOperator(
    task_id='pipeline_complete',
    dag=dag,
)

# ============================================================================
# Task Dependencies
# ============================================================================

# Layer 1: Staging
start >> run_staging >> test_staging

# Layer 2: Dimensions (depends on staging)
test_staging >> run_dimensions >> test_dimensions

# Layer 3: Facts (depends on dimensions)
test_dimensions >> run_facts >> test_facts

# Layer 4: Aggregates (depends on facts)
test_facts >> run_aggregates >> test_aggregates

# Data Quality: Custom tests (runs after aggregates)
test_aggregates >> run_custom_tests

# Final validation and documentation
run_custom_tests >> run_full_test_suite >> generate_docs >> end

# ============================================================================
# DAG Documentation
# ============================================================================

dag.doc_md = """
# Maven Fuzzy Factory Data Pipeline

## Overview
This DAG orchestrates the complete data transformation pipeline for Maven Fuzzy Factory,
an e-commerce toy store analytics platform.

## Pipeline Architecture

### 1. Staging Layer (6 models)
- Clean and standardize raw data
- Apply consistent naming conventions
- Handle data type conversions
- **Models:** stg_orders, stg_order_items, stg_order_item_refunds, stg_products,
  stg_website_sessions, stg_website_pageviews

### 2. Dimension Tables (5 models)
- Build slowly changing dimensions
- Create date dimension (2012-2015)
- Extract channel, device, product, and page dimensions
- **Models:** dim_date, dim_channel, dim_device, dim_product, dim_page

### 3. Fact Tables (5 models)
- Build transaction fact tables
- Join with dimensions
- Calculate business metrics
- **Models:** fact_sessions, fact_pageviews, fact_orders, fact_order_items, fact_refunds
- **Volume:** 1.7M+ records total

### 4. Aggregate Tables (4 models)
- Pre-aggregate metrics for dashboard performance
- **Models:** agg_daily_traffic, agg_channel_performance, agg_product_performance,
  agg_funnel_metrics
- **Volume:** 1,126 rows total

### 5. Data Quality Tests (266 tests)
- Source tests: 48
- Staging tests: 38
- Dimension tests: 42
- Fact tests: 90
- Aggregate tests: 25
- Custom business logic tests: 13
- Generic tests: 10

## Performance
- **Build Time:** ~41 seconds end-to-end (20 models)
- **Test Time:** ~20 seconds (266 tests)
- **Total Runtime:** ~61 seconds
- **Success Rate:** 100% (all tests passing)

## Data Freshness
- Raw data covers: 2012-03-19 to 2015-03-19 (3 years)
- Pipeline processes: 472,871 sessions, 1.2M pageviews, 32,313 orders
- Refresh frequency: Daily at 2 AM UTC

## Monitoring
- All tasks have 2 retries with 5-minute delay
- Execution timeout: 30 minutes per task
- Email notifications: Disabled (configure for production)

## Dependencies
- dbt-core 1.11.2
- PostgreSQL database: maven_fuzzy_factory
- Python 3.12 virtual environment

## Owner
Data Engineering Team
"""
