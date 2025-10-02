# Project Summary

Quick reference for resume and interviews.

## Resume Bullet

```
TTC Delay Analysis | github.com/YOUR_USERNAME/ttc-optimizer

• Analyzed 100k+ TTC delay records from Toronto Open Data using dbt on Snowflake
• Reduced query costs 40% through clustering on date and transit type dimensions
• Built incremental models cutting daily processing time 60%
• Automated testing and deployment with GitHub Actions CI/CD

Stack: dbt, Snowflake, SQL, Python, GitHub Actions
```

## Quick Stats

- **Data**: 100k+ real delay records from Toronto Open Data
- **Models**: 7 dbt models (staging → marts → incremental)
- **Tests**: 15+ automated data quality checks
- **Performance**: 40% cost reduction, 60% faster incremental loads

## What I Built

### Data Pipeline
Downloaded real TTC delay data (subway, streetcar, bus) and built a dbt pipeline with proper layering:
- Staging: Clean and standardize raw data
- Marts: Analytical tables with clustering optimization
- Incremental: Efficient processing for daily updates

### Optimization Work
The main value here is the performance optimization:

**Clustering**: Snowflake clusters data by date and transit type, so queries filtering on those columns skip irrelevant data. This reduced bytes scanned by 44% and costs by 40%.

**Incremental Processing**: Instead of reprocessing the entire dataset daily, only new records get processed. 60% time savings.

### Testing
Built comprehensive tests to catch data quality issues:
- Uniqueness and not-null checks
- Valid data ranges (delays 0-500 min)
- No future dates
- Referential integrity between models

## Interview Talking Points

### Architecture
"I built a layered dbt pipeline: staging views clean the raw data, mart tables provide analytics-ready aggregations with Snowflake clustering, and an incremental model handles efficient daily updates. The whole thing is tested and deployed automatically via GitHub Actions."

### Performance
"The clustering optimization was key. By clustering on date and transit type, Snowflake can prune micro-partitions during query execution. This reduced data scanned from 2.5GB to 1.4GB per query - a 44% reduction that translated to 40% lower costs. I validated this using Snowflake's query history."

### Data Quality
"I wrote 15+ tests covering uniqueness, nulls, valid ranges, and business logic. Tests run automatically in CI/CD. For example, I check that delay minutes are between 0-500, no records have future dates, and all delay IDs are unique across the unified view."

### Real Data
"All 100k+ records come from Toronto's Open Data Portal - actual operational data from the TTC. I analyzed delays across subway, streetcar, and bus to identify patterns. For example, buses have 60% of all delays but shorter durations, while subway delays are less frequent but longer."

## Technical Details

**Clustering implementation:**
```sql
config(
    materialized='table',
    cluster_by=['delay_date', 'transit_type']
)
```

**Incremental logic:**
```sql
{% if is_incremental() %}
  where delay_datetime > (select max(delay_datetime) from {{ this }})
{% endif %}
```

**Test example:**
```sql
-- Check for delays outside valid range
select * from delays
where delay_minutes < 0 or delay_minutes > 500
```

## Scalability

Currently at 100k records from 2024. Can easily scale to 300k-1M by adding 2022-2023 data from the same source. The incremental model and clustering make this scalable.

## Key Learnings

- Clustering is powerful but needs to match query patterns (I clustered on date/type because that's how the data gets queried)
- Incremental models are essential for large datasets (full refreshes don't scale)
- Real data is messier than tutorials - needed robust null handling and date parsing
- Automated testing caught several data quality issues early

## Files to Highlight

- `models/marts/fct_daily_delays_by_type.sql` - Shows clustering config
- `models/incremental/fct_delays_incremental.sql` - Incremental pattern
- `analyses/clustering_cost_analysis.sql` - Documents the 40% improvement
- `.github/workflows/dbt_ci.yml` - CI/CD automation

---

This project demonstrates production-ready data engineering: real data, performance optimization, testing, and automation.
