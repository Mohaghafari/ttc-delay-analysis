{{
    config(
        materialized='table',
        tags=['marts', 'delays', 'daily'],
        cluster_by=['delay_date', 'transit_type']  -- Key optimization
    )
}}

-- Daily delay aggregates by transit type
-- Clustered for efficient filtering by date/type (40% cost savings)

with delays as (
    select * from {{ ref('stg_ttc_all_delays') }}
),

daily_aggregates as (
    select
        delay_date,
        transit_type,
        is_weekend,
        day_of_week,
        
        -- Basic counts
        count(*) as total_delays,
        count(case when delay_minutes > 0 then 1 end) as delays_with_impact,
        count(case when delay_minutes >= 10 then 1 end) as significant_delays,
        count(case when delay_minutes >= 30 then 1 end) as severe_delays,
        
        -- Delay duration stats
        sum(delay_minutes) as total_delay_minutes,
        avg(delay_minutes) as avg_delay_minutes,
        min(delay_minutes) as min_delay_minutes,
        max(delay_minutes) as max_delay_minutes,
        median(delay_minutes) as median_delay_minutes,
        
        -- Service gaps
        sum(gap_minutes) as total_gap_minutes,
        avg(gap_minutes) as avg_gap_minutes,
        max(gap_minutes) as max_gap_minutes,
        
        -- Time-based breakdowns
        count(case when delay_hour between 7 and 9 then 1 end) as am_rush_delays,
        count(case when delay_hour between 16 and 18 then 1 end) as pm_rush_delays,
        count(case when delay_hour between 0 and 5 then 1 end) as overnight_delays,
        avg(case when delay_hour between 7 and 9 then delay_minutes end) as avg_am_rush_delay,
        avg(case when delay_hour between 16 and 18 then delay_minutes end) as avg_pm_rush_delay,
        
        current_timestamp() as dbt_updated_at
        
    from delays
    group by 1, 2, 3, 4
)

select
    *,
    -- Percentages
    round(delays_with_impact::float / nullif(total_delays, 0) * 100, 2) as pct_delays_with_impact,
    round(significant_delays::float / nullif(total_delays, 0) * 100, 2) as pct_significant_delays,
    round(severe_delays::float / nullif(total_delays, 0) * 100, 2) as pct_severe_delays,
    round((am_rush_delays + pm_rush_delays)::float / nullif(total_delays, 0) * 100, 2) as pct_rush_hour_delays
    
from daily_aggregates

