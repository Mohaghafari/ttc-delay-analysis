{{
    config(
        materialized='table',
        tags=['marts', 'delays', 'causes'],
        cluster_by=['delay_date', 'delay_cause']
    )
}}

with delays as (
    select * from {{ ref('stg_ttc_all_delays') }}
),

cause_analysis as (
    select
        delay_date,
        delay_year,
        delay_month,
        transit_type,
        delay_cause,
        is_weekend,
        
        -- Incident counts
        count(*) as incident_count,
        count(distinct vehicle_id) as unique_vehicles_affected,
        count(distinct location) as unique_locations,
        
        -- Delay impact
        sum(delay_minutes) as total_delay_minutes,
        avg(delay_minutes) as avg_delay_minutes,
        max(delay_minutes) as max_delay_minutes,
        
        -- Service impact
        sum(gap_minutes) as total_gap_minutes,
        avg(gap_minutes) as avg_gap_minutes,
        
        -- Time patterns
        count(case when delay_hour between 7 and 9 then 1 end) as am_rush_incidents,
        count(case when delay_hour between 16 and 18 then 1 end) as pm_rush_incidents,
        
        current_timestamp() as dbt_updated_at
        
    from delays
    where delay_cause is not null
    group by 1, 2, 3, 4, 5, 6
)

select
    *,
    -- Calculate severity score (weighted metric)
    round(
        (avg_delay_minutes * 0.4 + 
         avg_gap_minutes * 0.3 + 
         incident_count * 0.3), 
        2
    ) as severity_score
    
from cause_analysis

