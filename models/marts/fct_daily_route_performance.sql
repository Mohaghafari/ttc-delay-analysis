{{
    config(
        materialized='table',
        tags=['marts', 'daily', 'performance'],
        cluster_by=['trip_date', 'route_id']
    )
}}

with trips as (
    select * from {{ ref('int_trips_enriched') }}
),

daily_metrics as (
    select
        trip_date,
        route_id,
        route_name,
        route_type,
        is_weekend,
        
        -- Trip counts
        count(*) as total_trips,
        count(case when boarding_status = 'On Time' then 1 end) as on_time_trips,
        count(case when boarding_status = 'Delayed' then 1 end) as delayed_trips,
        count(case when boarding_status = 'Early' then 1 end) as early_trips,
        
        -- Passenger metrics
        sum(passengers) as total_passengers,
        avg(passengers) as avg_passengers_per_trip,
        max(passengers) as max_passengers,
        min(passengers) as min_passengers,
        
        -- Revenue metrics
        sum(trip_revenue) as total_revenue,
        sum(fare_amount) as total_fares_collected,
        avg(fare_amount) as avg_fare_per_passenger,
        
        -- Fare evasion
        count(case when is_fare_evasion then 1 end) as fare_evasion_count,
        
        -- Delay metrics
        avg(delay_minutes) as avg_delay_minutes,
        max(delay_minutes) as max_delay_minutes,
        percentile_cont(0.5) within group (order by delay_minutes) as median_delay_minutes,
        
        -- Peak time analysis
        count(case when time_period = 'Morning Rush' then 1 end) as morning_rush_trips,
        count(case when time_period = 'Evening Rush' then 1 end) as evening_rush_trips,
        
        -- Payment distribution
        count(case when payment_type = 'Presto' then 1 end) as presto_count,
        count(case when payment_type = 'Cash' then 1 end) as cash_count,
        count(case when payment_type = 'Monthly Pass' then 1 end) as monthly_pass_count,
        
        -- Environmental
        avg(temperature_celsius) as avg_temperature,
        
        current_timestamp() as dbt_updated_at
        
    from trips
    group by 1, 2, 3, 4, 5
)

select
    *,
    -- Calculated KPIs
    round(on_time_trips::float / nullif(total_trips, 0) * 100, 2) as on_time_percentage,
    round(delayed_trips::float / nullif(total_trips, 0) * 100, 2) as delay_percentage,
    round(fare_evasion_count::float / nullif(total_passengers, 0) * 100, 2) as fare_evasion_rate,
    round(presto_count::float / nullif(total_trips, 0) * 100, 2) as presto_adoption_rate
    
from daily_metrics

