#!/usr/bin/env python3
"""
============================================================================
Maven Fuzzy Factory - Raw Data Ingestion Script
============================================================================
Description: Loads CSV files into PostgreSQL raw schema tables
Author: suhaib921 (Suhaib abdi)
Created: 2026-01-20
============================================================================

This script:
1. Reads CSV files from the data directory
2. Loads them into the raw schema tables
3. Populates audit columns (_load_timestamp, _source_file)
4. Reports progress and row counts
5. Handles errors gracefully

Usage:
    python scripts/load_raw_data.py
    python scripts/load_raw_data.py --truncate  # Truncate tables before loading
"""

import os
import sys
import argparse
import logging
from datetime import datetime
from pathlib import Path

import pandas as pd
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values

# ============================================================================
# CONFIGURATION
# ============================================================================

# Database connection parameters
# Using Unix socket authentication (no password required)
DB_CONFIG = {
    'database': 'maven_fuzzy_factory',
    'user': 'suhkth'
}

# CSV file mapping: table_name -> csv_filename
CSV_FILES = {
    'products': 'products.csv',
    'website_sessions': 'website_sessions.csv',
    'website_pageviews': 'website_pageviews.csv',
    'orders': 'orders.csv',
    'order_items': 'order_items.csv',
    'order_item_refunds': 'order_item_refunds.csv'
}

# Expected row counts for validation
EXPECTED_COUNTS = {
    'products': 4,
    'website_sessions': 472871,
    'website_pageviews': 1188124,
    'orders': 32313,
    'order_items': 40025,
    'order_item_refunds': 1731
}

# ============================================================================
# LOGGING SETUP
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('data_ingestion.log')
    ]
)
logger = logging.getLogger(__name__)

# ============================================================================
# DATABASE FUNCTIONS
# ============================================================================

def get_db_connection():
    """Create and return a PostgreSQL database connection."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        logger.info("✓ Database connection established")
        return conn
    except Exception as e:
        logger.error(f"✗ Failed to connect to database: {e}")
        sys.exit(1)


def truncate_table(conn, table_name):
    """Truncate a table in the raw schema."""
    try:
        with conn.cursor() as cur:
            cur.execute(sql.SQL("TRUNCATE TABLE raw.{} CASCADE").format(
                sql.Identifier(table_name)
            ))
            conn.commit()
            logger.info(f"  ✓ Truncated raw.{table_name}")
    except Exception as e:
        logger.error(f"  ✗ Failed to truncate raw.{table_name}: {e}")
        conn.rollback()
        raise


def get_table_count(conn, table_name):
    """Get the current row count for a table."""
    try:
        with conn.cursor() as cur:
            cur.execute(sql.SQL("SELECT COUNT(*) FROM raw.{}").format(
                sql.Identifier(table_name)
            ))
            count = cur.fetchone()[0]
            return count
    except Exception as e:
        logger.error(f"  ✗ Failed to get count for raw.{table_name}: {e}")
        return -1


# ============================================================================
# DATA LOADING FUNCTIONS
# ============================================================================

def find_csv_file(csv_filename):
    """Find the CSV file in the project directory structure."""
    # Try multiple possible locations
    possible_paths = [
        Path(f"../Maven+Fuzzy+Factory/{csv_filename}"),
        Path(f"/home/suhkth/Desktop/Toy Store E-Commerce Database/Maven+Fuzzy+Factory/{csv_filename}"),
        Path(f"data/{csv_filename}"),
        Path(csv_filename)
    ]

    for path in possible_paths:
        if path.exists():
            return path

    logger.error(f"  ✗ Could not find {csv_filename} in any expected location")
    raise FileNotFoundError(f"CSV file not found: {csv_filename}")


def load_csv_to_table(conn, table_name, csv_filename):
    """Load a CSV file into a raw table."""
    try:
        # Find the CSV file
        csv_path = find_csv_file(csv_filename)
        logger.info(f"\n{'='*70}")
        logger.info(f"Loading: {table_name}")
        logger.info(f"Source: {csv_path}")
        logger.info(f"{'='*70}")

        # Read CSV file
        logger.info(f"  → Reading CSV file...")
        df = pd.read_csv(csv_path)
        original_count = len(df)
        logger.info(f"  ✓ Read {original_count:,} rows from CSV")

        # Add audit columns
        df['_load_timestamp'] = datetime.now()
        df['_source_file'] = csv_filename

        # Handle NULL values for text columns (empty strings to None)
        df = df.where(pd.notnull(df), None)

        # Prepare data for insertion
        columns = df.columns.tolist()
        data = [tuple(row) for row in df.values]

        # Build INSERT statement
        insert_query = sql.SQL(
            "INSERT INTO raw.{table} ({fields}) VALUES %s"
        ).format(
            table=sql.Identifier(table_name),
            fields=sql.SQL(', ').join(map(sql.Identifier, columns))
        )

        # Execute batch insert
        logger.info(f"  → Inserting data into raw.{table_name}...")
        with conn.cursor() as cur:
            execute_values(
                cur,
                insert_query.as_string(conn),
                data,
                page_size=1000
            )
        conn.commit()

        # Verify row count
        final_count = get_table_count(conn, table_name)
        logger.info(f"  ✓ Inserted {final_count:,} rows into raw.{table_name}")

        # Validate against expected count
        expected = EXPECTED_COUNTS.get(table_name, 0)
        if expected > 0:
            if final_count == expected:
                logger.info(f"  ✓ Row count matches expected: {expected:,}")
            else:
                logger.warning(f"  ⚠ Row count mismatch! Expected: {expected:,}, Got: {final_count:,}")

        return final_count

    except Exception as e:
        logger.error(f"  ✗ Failed to load {table_name}: {e}")
        conn.rollback()
        raise


# ============================================================================
# MAIN EXECUTION
# ============================================================================

def main():
    """Main execution function."""
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Load CSV data into raw schema tables')
    parser.add_argument('--truncate', action='store_true',
                       help='Truncate tables before loading')
    args = parser.parse_args()

    # Start
    start_time = datetime.now()
    logger.info("\n" + "="*70)
    logger.info("Maven Fuzzy Factory - Raw Data Ingestion")
    logger.info("="*70)
    logger.info(f"Started at: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")

    # Connect to database
    conn = get_db_connection()

    try:
        # Truncate tables if requested
        if args.truncate:
            logger.info("\n" + "="*70)
            logger.info("TRUNCATING TABLES")
            logger.info("="*70)
            for table_name in CSV_FILES.keys():
                truncate_table(conn, table_name)

        # Load each CSV file
        logger.info("\n" + "="*70)
        logger.info("LOADING DATA")
        logger.info("="*70)

        total_rows = 0
        results = {}

        for table_name, csv_filename in CSV_FILES.items():
            try:
                row_count = load_csv_to_table(conn, table_name, csv_filename)
                results[table_name] = {'status': 'SUCCESS', 'rows': row_count}
                total_rows += row_count
            except Exception as e:
                results[table_name] = {'status': 'FAILED', 'error': str(e)}

        # Summary
        logger.info("\n" + "="*70)
        logger.info("SUMMARY")
        logger.info("="*70)

        success_count = sum(1 for r in results.values() if r['status'] == 'SUCCESS')
        failed_count = sum(1 for r in results.values() if r['status'] == 'FAILED')

        for table_name, result in results.items():
            status_icon = "✓" if result['status'] == 'SUCCESS' else "✗"
            if result['status'] == 'SUCCESS':
                logger.info(f"{status_icon} {table_name:25s} {result['rows']:>10,} rows")
            else:
                logger.error(f"{status_icon} {table_name:25s} FAILED: {result.get('error', 'Unknown error')}")

        logger.info(f"\n{'='*70}")
        logger.info(f"Total tables processed: {len(CSV_FILES)}")
        logger.info(f"Successful: {success_count}")
        logger.info(f"Failed: {failed_count}")
        logger.info(f"Total rows loaded: {total_rows:,}")

        # Execution time
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        logger.info(f"Duration: {duration:.2f} seconds")
        logger.info(f"Completed at: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
        logger.info("="*70 + "\n")

        # Exit with appropriate code
        sys.exit(0 if failed_count == 0 else 1)

    except Exception as e:
        logger.error(f"\n✗ Ingestion failed with error: {e}")
        sys.exit(1)
    finally:
        conn.close()
        logger.info("Database connection closed")


if __name__ == "__main__":
    main()
