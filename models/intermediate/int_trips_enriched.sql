{{
    config(
        materialized='view',
        tags=['intermediate', 'enriched']
    )
}}

with trips as (
    select * from {{ ref('stg_ttc_trips') }}
),

routes as (
    select * from {{ ref('stg_route_info') }}
),

enriched as (
    select
        t.trip_id,
        t.trip_datetime,
        t.trip_date,
        t.trip_year,
        t.trip_month,
        t.trip_day,
        t.trip_hour,
        t.day_of_week,
        t.is_weekend,
        
        -- Route details
        t.route_id,
        r.route_name,
        r.route_type,
        r.avg_fare as route_avg_fare,
        
        -- Trip metrics
        t.passengers,
        t.payment_type,
        t.fare_amount,
        t.boarding_status,
        t.delay_minutes,
        
        -- Calculated fields
        case 
            when t.trip_hour between 7 and 9 then 'Morning Rush'
            when t.trip_hour between 16 and 18 then 'Evening Rush'
            when t.trip_hour between 10 and 15 then 'Midday'
            when t.trip_hour between 19 and 22 then 'Evening'
            else 'Off-Peak'
        end as time_period,
        
        case
            when t.delay_minutes > 5 then 'Significantly Delayed'
            when t.delay_minutes > 0 then 'Slightly Delayed'
            when t.delay_minutes = 0 then 'On Time'
            else 'Early'
        end as delay_category,
        
        case
            when t.fare_amount = 0 then true
            else false
        end as is_fare_evasion,
        
        t.passengers * t.fare_amount as trip_revenue,
        
        -- Operational data
        t.vehicle_id,
        t.stop_sequence,
        t.temperature_celsius,
        
        -- Metadata
        t.dbt_loaded_at
        
    from trips t
    left join routes r
        on t.route_id = r.route_id
)

select * from enriched

