# Setup Guide

Instructions for running this project locally or on Snowflake.

## Prerequisites

- Python 3.11 or higher
- Snowflake account (free trial works fine)
- Basic SQL knowledge

## Local Setup

### 1. Clone and Install

```bash
git clone https://github.com/Mohaghafari/ttc-delay-analysis.git
cd ttc-delay-analysis

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Install dbt Packages

```bash
dbt deps
```

This installs dbt_utils which we use for some tests.

## Snowflake Setup

### 1. Create Database and Warehouse

Log into Snowflake and run:

```sql
USE ROLE ACCOUNTADMIN;

-- Create warehouse
CREATE WAREHOUSE COMPUTE_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create database
CREATE DATABASE TTC_ANALYTICS;

-- Create schemas
CREATE SCHEMA TTC_ANALYTICS.DEV;
CREATE SCHEMA TTC_ANALYTICS.PROD;
CREATE SCHEMA TTC_ANALYTICS.RAW;
```

### 2. Configure Connection

Option A - Environment variables (recommended):

```bash
export SNOWFLAKE_ACCOUNT="abc123.us-east-1"
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
```

Option B - Update `~/.dbt/profiles.yml`:

```bash
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml
# Edit ~/.dbt/profiles.yml with your credentials
```

### 3. Test Connection

```bash
dbt debug
```

Should see all green checks if everything is configured correctly.

## Running the Pipeline

### Load Data

```bash
dbt seed
```

This loads the 100k+ delay records from CSV into Snowflake.

### Run Models

```bash
# Run all models
dbt run

# Or run specific layers
dbt run --select staging
dbt run --select marts
```

### Run Tests

```bash
dbt test
```

### Run Everything

```bash
dbt build
```

This runs seeds, models, and tests in the correct order.

## Verify Data Loaded

In Snowflake, run:

```sql
USE DATABASE TTC_ANALYTICS;
USE SCHEMA RAW;

-- Check row counts
SELECT 'subway' as type, COUNT(*) as rows FROM ttc_subway_delays
UNION ALL
SELECT 'streetcar', COUNT(*) FROM ttc_streetcar_delays
UNION ALL  
SELECT 'bus', COUNT(*) FROM ttc_bus_delays;

-- Should see: subway ~26k, streetcar ~14k, bus ~60k
```

## View Documentation

```bash
dbt docs generate
dbt docs serve
```

Open http://localhost:8080 to see data lineage and model docs.

## CI/CD Setup (Optional)

To enable GitHub Actions:

1. Push code to GitHub
2. Go to Settings → Secrets → Actions
3. Add these secrets:
   - SNOWFLAKE_ACCOUNT
   - SNOWFLAKE_USER
   - SNOWFLAKE_PASSWORD
   - SNOWFLAKE_ROLE
   - SNOWFLAKE_WAREHOUSE
   - SNOWFLAKE_DATABASE

The workflow in `.github/workflows/dbt_ci.yml` will run automatically on pushes.

## Adding More Data

Want more than 100k records?

1. Download 2022-2024 data from Toronto Open Data:
   - https://open.toronto.ca/dataset/ttc-subway-delay-data/
   - https://open.toronto.ca/dataset/ttc-streetcar-delay-data/
   - https://open.toronto.ca/dataset/ttc-bus-delay-data/

2. Place Excel files in `data/raw/`

3. Convert to CSV:
   ```bash
   python scripts/convert_excel_to_csv.py
   ```

4. Reload:
   ```bash
   dbt seed --full-refresh
   dbt build
   ```

## Troubleshooting

**dbt debug fails**
- Check environment variables are set
- Verify Snowflake credentials
- Make sure profiles.yml is in ~/.dbt/

**Seed takes forever**
- Normal for 100k records, takes a few minutes
- Increase Snowflake warehouse size if needed

**Tests fail**
- Check `target/run_results.json` for details
- Failed tests store results in test_failures schema

**Connection timeout**
- Check Snowflake account identifier format: `account.region`
- Verify warehouse is running

## Common Commands

```bash
# List all models
dbt list

# Run specific model
dbt run --select fct_daily_delays_by_type

# Test specific model
dbt test --select stg_ttc_all_delays

# Compile SQL (see what dbt generates)
dbt compile

# Clean up
dbt clean
```

## Performance Tips

- Use `XSMALL` warehouse for development (cheaper)
- Enable `AUTO_SUSPEND` to minimize costs
- Run `dbt run --select marts` to only rebuild marts
- Use `--full-refresh` flag when data changes significantly

That's it. Should be straightforward to get running locally or on Snowflake.
