# 🚀 Quick Start Guide

Get your TTC Analytics project running in 10 minutes!

## Prerequisites

- ✅ Python 3.11+ installed
- ✅ Snowflake account ([Get free trial](https://signup.snowflake.com/))
- ✅ GitHub account

## Setup Steps

### 1. Verify Installation

```bash
# Check you're in the project directory
cd "/Users/apple/Desktop/TTC Analysis"

# Verify Python version
python3 --version  # Should be 3.11+

# Virtual environment already created!
source venv/bin/activate
```

### 2. Configure Snowflake

#### Option A: Using Environment Variables (Recommended)

```bash
# Set these in your terminal or add to ~/.zshrc
export SNOWFLAKE_ACCOUNT="abc12345.us-east-1"  # Your account identifier
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
```

#### Option B: Update profiles.yml

```bash
# Copy template to ~/.dbt/
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml

# Edit with your credentials
nano ~/.dbt/profiles.yml
```

### 3. Set Up Snowflake Database

Log into Snowflake and run:

```sql
USE ROLE ACCOUNTADMIN;

-- Create warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- Create database
CREATE DATABASE IF NOT EXISTS TTC_ANALYTICS;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.DEV;
CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.PROD;
CREATE SCHEMA IF NOT EXISTS TTC_ANALYTICS.RAW;
```

### 4. Run the Project!

```bash
# Activate virtual environment (if not already)
source venv/bin/activate

# Install dbt packages
dbt deps

# Test connection
dbt debug

# Load seed data (route info + 100k trip records already generated!)
dbt seed

# Run all models and tests
dbt build

# Success! 🎉
```

### 5. View Results

#### In Snowflake:

```sql
-- Check data loaded
SELECT COUNT(*) FROM TTC_ANALYTICS.RAW.TTC_TRIPS;

-- View daily performance metrics
SELECT 
    trip_date,
    route_name,
    total_passengers,
    on_time_percentage,
    total_revenue
FROM TTC_ANALYTICS.DEV.FCT_DAILY_ROUTE_PERFORMANCE
ORDER BY trip_date DESC, total_passengers DESC
LIMIT 20;
```

#### View dbt Documentation:

```bash
dbt docs generate
dbt docs serve
# Open http://localhost:8080 in your browser
```

## Generate Full Dataset (Optional)

```bash
# Generate 1 million records (~5 minutes, 500MB)
python scripts/generate_ttc_data.py 1000000

# Generate 10 million records (~30 minutes, 5GB)
python scripts/generate_ttc_data.py 10000000

# Reload seeds
dbt seed --full-refresh

# Rebuild models
dbt build --full-refresh
```

## Push to GitHub

### Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `ttc-optimizer`
3. Description: `Toronto Transit Analytics using dbt on Snowflake`
4. Make it **Public** (for portfolio visibility!)
5. **Don't** initialize with README (we already have one)
6. Click "Create repository"

### Push Your Code

```bash
# Update your GitHub username in the remote URL
git remote add origin https://github.com/YOUR_USERNAME/ttc-optimizer.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Configure GitHub Secrets (for CI/CD)

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Add these secrets:
   - `SNOWFLAKE_ACCOUNT`: your_account.region
   - `SNOWFLAKE_USER`: your_username
   - `SNOWFLAKE_PASSWORD`: your_password
   - `SNOWFLAKE_ROLE`: ACCOUNTADMIN
   - `SNOWFLAKE_WAREHOUSE`: COMPUTE_WH
   - `SNOWFLAKE_DATABASE`: TTC_ANALYTICS

### Test CI/CD

```bash
# Make a small change
echo "\n<!-- CI/CD test -->" >> README.md

git add README.md
git commit -m "Test: Trigger CI/CD pipeline"
git push

# Check GitHub Actions tab to see pipeline running!
```

## Troubleshooting

### dbt debug fails?

```bash
# Check environment variables
env | grep SNOWFLAKE

# Verify profiles.yml exists
cat ~/.dbt/profiles.yml
```

### Permission errors in Snowflake?

```sql
-- Grant necessary permissions
USE ROLE ACCOUNTADMIN;
GRANT ALL ON DATABASE TTC_ANALYTICS TO ROLE YOUR_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE YOUR_ROLE;
```

### Can't see dbt docs?

```bash
# Make sure you're in project directory
cd "/Users/apple/Desktop/TTC Analysis"

# Regenerate docs
dbt docs generate

# Serve on different port if 8080 is busy
dbt docs serve --port 8081
```

## Next Steps

✅ **For Your Resume:**
- Update README.md with your name and GitHub username
- Take screenshots of dbt docs for your portfolio
- Add project link to your resume under "Projects"

✅ **Enhance the Project:**
- Add more complex SQL transformations
- Implement dbt snapshots for historical tracking
- Create visualizations with Tableau/PowerBI
- Add dbt exposures for downstream BI tools
- Implement dbt metrics

✅ **Learn More:**
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Snowflake Optimization](https://docs.snowflake.com/en/user-guide/performance-optimization)
- [dbt Learn](https://courses.getdbt.com/collections)

## Project Structure

```
ttc-optimizer/
├── models/
│   ├── staging/          # Raw data transformations
│   ├── intermediate/     # Business logic
│   ├── marts/           # Final analytics tables (clustered)
│   └── incremental/     # Efficient incremental models
├── tests/               # Custom data quality tests
├── macros/              # Reusable SQL functions
├── seeds/               # Reference data
├── analyses/            # Ad-hoc analyses
├── scripts/             # Data generation
├── .github/workflows/   # CI/CD automation
└── docs/               # Documentation

```

## Support

- **Full Guide**: See `SETUP_GUIDE.md`
- **Questions?**: Open an issue on GitHub
- **dbt Help**: [dbt Slack Community](https://www.getdbt.com/community/join-the-community)

---

**Built with ❤️ for learning and portfolio development**

Good luck with your interviews! 🎯

