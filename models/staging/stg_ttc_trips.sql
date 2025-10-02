{{
    config(
        materialized='view',
        tags=['staging', 'trips']
    )
}}

with source as (
    select * from {{ ref('ttc_trips') }}
),

renamed as (
    select
        -- Primary Key
        trip_id,
        
        -- Temporal columns
        trip_datetime,
        date(trip_datetime) as trip_date,
        extract(year from trip_datetime) as trip_year,
        extract(month from trip_datetime) as trip_month,
        extract(day from trip_datetime) as trip_day,
        extract(hour from trip_datetime) as trip_hour,
        extract(dayofweek from trip_datetime) as day_of_week,
        case 
            when extract(dayofweek from trip_datetime) in (0, 6) then true
            else false
        end as is_weekend,
        
        -- Route information
        route_id,
        route_name,
        route_type,
        
        -- Trip metrics
        passengers,
        payment_type,
        fare_amount,
        boarding_status,
        delay_minutes,
        
        -- Operational data
        vehicle_id,
        stop_sequence,
        
        -- Environmental data
        temperature_celsius,
        
        -- Metadata
        created_at as source_created_at,
        current_timestamp() as dbt_loaded_at
        
    from source
)

select * from renamed

