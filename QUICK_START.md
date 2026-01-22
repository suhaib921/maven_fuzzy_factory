# Maven Fuzzy Factory - Quick Start Guide

Get your data engineering pipeline up and running in 30 minutes!

## Prerequisites

- Ubuntu/Debian Linux (or WSL2 on Windows)
- Python 3.9+ installed
- At least 4GB RAM
- 10GB free disk space
- Terminal/command line access

## 🚀 Quick Setup (30 minutes)

### Step 1: Install PostgreSQL (5 minutes)

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify installation
sudo -u postgres psql -c "SELECT version();"
```

**Expected output:** PostgreSQL version information

---

### Step 2: Create Project Directory (2 minutes)

```bash
# Navigate to project location
cd "/home/suhkth/Desktop/Toy Store E-Commerce Database"

# Create directory structure
mkdir -p maven_fuzzy_factory/{data/raw,sql/ddl,scripts/utils,dbt,airflow/dags,metabase,docs,tests,notebooks,logs}

# Copy CSV files to data directory
cp Maven+Fuzzy+Factory/*.csv maven_fuzzy_factory/data/raw/

# Move into project directory
cd maven_fuzzy_factory

# Initialize Git
git init
cp ../.gitignore.template .gitignore
git add .gitignore
git commit -m "Initial commit: Add .gitignore"
```

---

### Step 3: Set Up Python Environment (5 minutes)

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r ../requirements.txt

# Verify installations
dbt --version
airflow version
python -c "import psycopg2; print('psycopg2 OK')"
```

---

### Step 4: Create PostgreSQL Database (3 minutes)

```bash
# Switch to postgres user and create database
sudo -u postgres psql << EOF
CREATE DATABASE maven_fuzzy_factory;
CREATE USER fuzzy_user WITH PASSWORD 'fuzzy_password_123';
GRANT ALL PRIVILEGES ON DATABASE maven_fuzzy_factory TO fuzzy_user;
\c maven_fuzzy_factory
GRANT ALL ON SCHEMA public TO fuzzy_user;
EOF

# Verify connection as new user
PGPASSWORD=fuzzy_password_123 psql -U fuzzy_user -d maven_fuzzy_factory -c "\dt"
```

**Expected output:** "Did not find any relations" (database is empty, which is correct)

---

### Step 5: Create Database Schemas (2 minutes)

Create file: `sql/ddl/01_create_schemas.sql`

```sql
-- Create schemas for data layers
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE SCHEMA IF NOT EXISTS aggregate;

-- Verify schemas
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('raw', 'staging', 'mart', 'aggregate');
```

Execute:
```bash
PGPASSWORD=fuzzy_password_123 psql -U fuzzy_user -d maven_fuzzy_factory -f sql/ddl/01_create_schemas.sql
```

**Expected output:** List of 4 schemas (raw, staging, mart, aggregate)

---

### Step 6: Create Environment File (2 minutes)

Create file: `.env`

```bash
# PostgreSQL Connection
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=maven_fuzzy_factory
POSTGRES_USER=fuzzy_user
POSTGRES_PASSWORD=fuzzy_password_123

# dbt
DBT_PROFILES_DIR=/home/suhkth/Desktop/Toy Store E-Commerce Database/maven_fuzzy_factory/dbt

# Airflow
AIRFLOW_HOME=/home/suhkth/Desktop/Toy Store E-Commerce Database/maven_fuzzy_factory/airflow
```

**⚠️ IMPORTANT:** Never commit .env file to Git! It's already in .gitignore.

---

### Step 7: Initialize dbt Project (5 minutes)

```bash
# Navigate to dbt directory
cd dbt

# Initialize dbt project
dbt init maven_fuzzy_factory

# When prompted:
# - Which database: postgres
# - host: localhost
# - port: 5432
# - user: fuzzy_user
# - pass: fuzzy_password_123
# - dbname: maven_fuzzy_factory
# - schema: staging
# - threads: 4

# Test connection
cd maven_fuzzy_factory
dbt debug

# Go back to project root
cd ../..
```

**Expected output:** "All checks passed!" from `dbt debug`

---

### Step 8: Verify Setup (3 minutes)

Run verification checklist:

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql | grep "active (running)"

# Check Python environment
python --version  # Should be 3.9+

# Check dbt
dbt --version  # Should be 1.7+

# Check database connection
PGPASSWORD=fuzzy_password_123 psql -U fuzzy_user -d maven_fuzzy_factory -c "SELECT current_database(), current_schema();"

# Check data files exist
ls -lh data/raw/*.csv

# Check virtual environment is active
echo $VIRTUAL_ENV  # Should show path to venv
```

---

### Step 9: Track Your Progress (2 minutes)

```bash
# Copy tracker to project
cp ../PROJECT_TRACKER.md .
cp ../PROJECT_STRUCTURE.md .
cp ../Project_overview.txt .

# Mark first task as in_progress
# (Claude will help you update this as you go)

# Make initial commit
git add .
git commit -m "chore: Initialize project structure and environment"
```

---

## ✅ Setup Complete!

You should now have:
- ✅ PostgreSQL database running
- ✅ Python virtual environment with all dependencies
- ✅ Database `maven_fuzzy_factory` with 4 schemas
- ✅ dbt project initialized and connected
- ✅ Git repository set up
- ✅ CSV data files in place
- ✅ Project structure ready

## 🎯 Next Steps

**You're ready to start building!** Follow the tasks in `PROJECT_TRACKER.md`:

1. **Phase 2:** Create raw table DDL scripts
2. **Phase 3:** Load CSV data into raw tables
3. **Phase 4:** Build dbt staging models
4. **Continue through all 12 phases...**

## 🆘 Troubleshooting

### PostgreSQL won't start
```bash
sudo systemctl restart postgresql
sudo tail -n 50 /var/log/postgresql/postgresql-14-main.log
```

### Can't connect to database
```bash
# Check if PostgreSQL is listening
sudo netstat -tlnp | grep 5432

# Verify user exists
sudo -u postgres psql -c "\du fuzzy_user"
```

### dbt debug fails
```bash
# Check profiles.yml exists
cat ~/.dbt/profiles.yml

# Verify database credentials
PGPASSWORD=fuzzy_password_123 psql -U fuzzy_user -d maven_fuzzy_factory -c "SELECT 1;"
```

### Python packages won't install
```bash
# Make sure you're in virtual environment
which python  # Should point to venv/bin/python

# Try installing one by one
pip install psycopg2-binary
pip install dbt-postgres
pip install apache-airflow
```

## 📚 Helpful Commands

### PostgreSQL
```bash
# Connect to database
PGPASSWORD=fuzzy_password_123 psql -U fuzzy_user -d maven_fuzzy_factory

# List all schemas
\dn

# List all tables in a schema
\dt raw.*

# Exit psql
\q
```

### Git
```bash
# Check status
git status

# View commit history
git log --oneline

# Create feature branch
git checkout -b feature/raw-layer
```

### Python Virtual Environment
```bash
# Activate
source venv/bin/activate

# Deactivate
deactivate

# List installed packages
pip list
```

### dbt
```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_sessions

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 🎓 Learning Resources

- **PostgreSQL Tutorial:** https://www.postgresql.org/docs/
- **dbt Docs:** https://docs.getdbt.com/
- **Airflow Docs:** https://airflow.apache.org/docs/
- **Dimensional Modeling:** "The Data Warehouse Toolkit" by Ralph Kimball

## 📞 Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review error messages carefully
3. Consult PROJECT_TRACKER.md for context
4. Ask Claude for help with specific error messages!

---

**Time to build something awesome!** 🚀

Start with Phase 2, Task 2.2 in PROJECT_TRACKER.md: Create raw table DDL scripts.
