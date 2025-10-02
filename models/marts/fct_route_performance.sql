{{
    config(
        materialized='table',
        tags=['marts', 'routes', 'performance'],
        cluster_by=['delay_date', 'line_route']
    )
}}

with delays as (
    select * from {{ ref('stg_ttc_all_delays') }}
    where line_route is not null
),

route_metrics as (
    select
        delay_date,
        delay_year,
        delay_month,
        day_of_week,
        is_weekend,
        line_route,
        transit_type,
        
        -- Delay counts
        count(*) as total_delays,
        count(case when delay_minutes >= 10 then 1 end) as significant_delays,
        count(distinct vehicle_id) as vehicles_with_delays,
        count(distinct location) as affected_locations,
        
        -- Delay duration
        sum(delay_minutes) as total_delay_minutes,
        avg(delay_minutes) as avg_delay_minutes,
        max(delay_minutes) as max_delay_minutes,
        percentile_cont(0.5) within group (order by delay_minutes) as median_delay_minutes,
        percentile_cont(0.90) within group (order by delay_minutes) as p90_delay_minutes,
        
        -- Service gaps
        sum(gap_minutes) as total_gap_minutes,
        avg(gap_minutes) as avg_gap_minutes,
        
        -- Peak analysis
        sum(case when delay_hour between 7 and 9 then delay_minutes else 0 end) as am_rush_delay_minutes,
        sum(case when delay_hour between 16 and 18 then delay_minutes else 0 end) as pm_rush_delay_minutes,
        
        -- Top delay cause (most frequent)
        mode() within group (order by delay_cause) as most_common_delay_cause,
        
        current_timestamp() as dbt_updated_at
        
    from delays
    group by 1, 2, 3, 4, 5, 6, 7
)

select
    *,
    -- Reliability score (inverse of delays - higher is better)
    round(100 - least(total_delays * 0.1, 50), 2) as reliability_score,
    
    -- Performance rating
    case
        when avg_delay_minutes < 5 then 'Excellent'
        when avg_delay_minutes < 10 then 'Good'
        when avg_delay_minutes < 20 then 'Fair'
        else 'Needs Improvement'
    end as performance_rating
    
from route_metrics

