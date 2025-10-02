{{
    config(
        materialized='table',
        tags=['marts', 'hourly', 'ridership'],
        cluster_by=['trip_date', 'trip_hour']
    )
}}

with trips as (
    select * from {{ ref('int_trips_enriched') }}
),

hourly_metrics as (
    select
        trip_date,
        trip_hour,
        time_period,
        is_weekend,
        
        -- Trip counts by route type
        count(*) as total_trips,
        count(case when route_type = 'Subway' then 1 end) as subway_trips,
        count(case when route_type = 'Bus' then 1 end) as bus_trips,
        count(case when route_type = 'Streetcar' then 1 end) as streetcar_trips,
        
        -- Ridership
        sum(passengers) as total_passengers,
        sum(case when route_type = 'Subway' then passengers end) as subway_passengers,
        sum(case when route_type = 'Bus' then passengers end) as bus_passengers,
        sum(case when route_type = 'Streetcar' then passengers end) as streetcar_passengers,
        
        -- Revenue
        sum(trip_revenue) as total_revenue,
        
        -- Performance
        avg(delay_minutes) as avg_delay_minutes,
        count(case when delay_category = 'Significantly Delayed' then 1 end) as significantly_delayed_count,
        
        current_timestamp() as dbt_updated_at
        
    from trips
    group by 1, 2, 3, 4
)

select * from hourly_metrics

