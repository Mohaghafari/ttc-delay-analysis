# 🚀 Complete Setup Guide

This guide will walk you through setting up the TTC Analytics project from scratch.

## Prerequisites Checklist

- [ ] Python 3.11 or higher installed
- [ ] Git installed
- [ ] Snowflake account (free trial available at snowflake.com)
- [ ] GitHub account
- [ ] Basic knowledge of SQL and command line

## Part 1: Local Development Setup (30 minutes)

### Step 1: Set Up Snowflake (10 minutes)

1. **Create Snowflake Account**
   - Go to https://signup.snowflake.com/
   - Choose AWS as cloud provider
   - Select region closest to you
   - Note your account identifier (e.g., `abc12345.us-east-1`)

2. **Create Database and Warehouse**
   ```sql
   -- Log into Snowflake and run in a worksheet:
   
   USE ROLE ACCOUNTADMIN;
   
   -- Create warehouse
   CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
       WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE;
   
   -- Create database
   CREATE DATABASE IF NOT EXISTS TTC_ANALYTICS;
   
   -- Create schemas
   CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.DEV;
   CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.PROD;
   CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.RAW;
   
   -- Verify
   SHOW WAREHOUSES;
   SHOW DATABASES;
   ```

3. **Get Your Credentials**
   - Account: Click your name (top right) → Account → Copy account identifier
   - Username: Your Snowflake username
   - Password: Your Snowflake password

### Step 2: Clone and Set Up Project (5 minutes)

```bash
# Create project directory
mkdir -p ~/projects/ttc-optimizer
cd ~/projects/ttc-optimizer

# Copy all files from "TTC Analysis" folder
# (The files we just created)

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure dbt Connection (5 minutes)

```bash
# Create .dbt directory in home folder
mkdir -p ~/.dbt

# Copy profiles.yml to .dbt directory
cp profiles.yml ~/.dbt/profiles.yml

# Set environment variables (Mac/Linux)
export SNOWFLAKE_ACCOUNT="your_account.region"
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"

# For Windows (PowerShell)
$env:SNOWFLAKE_ACCOUNT="your_account.region"
$env:SNOWFLAKE_USER="your_username"
$env:SNOWFLAKE_PASSWORD="your_password"
$env:SNOWFLAKE_ROLE="ACCOUNTADMIN"

# Test connection
dbt debug
```

### Step 4: Generate and Load Data (10 minutes)

```bash
# Install dbt packages
dbt deps

# Generate sample data (1M records for testing)
python scripts/generate_ttc_data.py 1000000

# This creates:
# - seeds/ttc_trips.csv (~100MB)
# - seeds/route_info.csv (~1KB)

# Load seeds into Snowflake
dbt seed

# Verify in Snowflake
# SELECT COUNT(*) FROM TTC_ANALYTICS.RAW.TTC_TRIPS;
```

### Step 5: Run dbt Models (5 minutes)

```bash
# Run all models
dbt build --full-refresh

# This will:
# 1. Run staging models (views)
# 2. Run intermediate models (views)
# 3. Run mart models (tables with clustering)
# 4. Run incremental models
# 5. Execute all tests

# View documentation
dbt docs generate
dbt docs serve
# Visit http://localhost:8080
```

## Part 2: GitHub Setup (15 minutes)

### Step 1: Create GitHub Repository

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Initial commit: TTC Analytics dbt project"

# Create repo on GitHub
# Go to github.com → New Repository
# Name: ttc-optimizer
# Description: Toronto Transit Analytics using dbt on Snowflake
# Public repository

# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/ttc-optimizer.git
git branch -M main
git push -u origin main
```

### Step 2: Configure GitHub Secrets

1. Go to your repository on GitHub
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret" and add:

   - `SNOWFLAKE_ACCOUNT`: your_account.region
   - `SNOWFLAKE_USER`: your_username
   - `SNOWFLAKE_PASSWORD`: your_password
   - `SNOWFLAKE_ROLE`: ACCOUNTADMIN
   - `SNOWFLAKE_WAREHOUSE`: COMPUTE_WH
   - `SNOWFLAKE_DATABASE`: TTC_ANALYTICS

### Step 3: Test GitHub Actions

```bash
# Make a small change
echo "Test CI/CD" >> README.md
git add README.md
git commit -m "Test: Trigger CI/CD pipeline"
git push

# Check GitHub Actions
# Go to your repo → Actions tab
# You should see the workflow running
```

## Part 3: Generate Full Dataset (Optional)

For the full 10M+ records experience:

```bash
# This takes ~30 minutes and generates ~1GB file
python scripts/generate_ttc_data.py 10000000

# Load into Snowflake
dbt seed --full-refresh

# Run models
dbt build --full-refresh
```

## Part 4: Verify Everything Works

### Checklist

- [ ] `dbt debug` shows green checkmarks
- [ ] `dbt seed` loads data successfully
- [ ] `dbt run` completes without errors
- [ ] `dbt test` passes all tests
- [ ] `dbt docs serve` shows documentation
- [ ] GitHub Actions workflow passes
- [ ] Can query tables in Snowflake

### Test Queries in Snowflake

```sql
-- Verify data loaded
SELECT COUNT(*) FROM TTC_ANALYTICS.RAW.TTC_TRIPS;

-- Check staging model
SELECT * FROM TTC_ANALYTICS.DEV.STG_TTC_TRIPS LIMIT 10;

-- Check mart model with clustering
SELECT 
    trip_date,
    route_name,
    total_trips,
    total_passengers,
    on_time_percentage
FROM TTC_ANALYTICS.DEV.FCT_DAILY_ROUTE_PERFORMANCE
WHERE trip_date = '2024-01-15'
ORDER BY total_passengers DESC;

-- Verify clustering is working
SHOW TABLES LIKE 'FCT_DAILY_ROUTE_PERFORMANCE';
-- Check CLUSTER_BY column
```

## Troubleshooting

### Issue: dbt debug fails

**Solution:**
```bash
# Check environment variables
echo $SNOWFLAKE_ACCOUNT
echo $SNOWFLAKE_USER

# Verify ~/.dbt/profiles.yml exists
cat ~/.dbt/profiles.yml

# Test Snowflake connection manually
python -c "import snowflake.connector; print('Connection library installed')"
```

### Issue: dbt seed takes too long

**Solution:**
```bash
# Generate smaller dataset first
python scripts/generate_ttc_data.py 100000

# Or increase Snowflake warehouse size
# In Snowflake: ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'SMALL';
```

### Issue: GitHub Actions fails

**Solution:**
- Verify all secrets are set correctly in GitHub
- Check that secret names match exactly (case-sensitive)
- Review workflow logs in GitHub Actions tab

## Next Steps

1. **Customize for Your Resume**
   - Update README.md with your GitHub username
   - Add your LinkedIn profile
   - Take screenshots of dbt docs for your portfolio

2. **Add More Features**
   - Create additional analyses
   - Add more tests
   - Implement dbt exposures for BI dashboards

3. **Optimize Further**
   - Experiment with different clustering keys
   - Implement data partitioning
   - Add snapshot models for slowly changing dimensions

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Snowflake Clustering Guide](https://docs.snowflake.com/en/user-guide/tables-clustering-keys)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review dbt logs in `logs/dbt.log`
3. Open an issue on GitHub
4. Search dbt Slack community

---

Good luck with your project! 🚀

