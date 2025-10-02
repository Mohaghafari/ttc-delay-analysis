{{
    config(
        materialized='view',
        tags=['staging', 'delays', 'bus']
    )
}}

with source as (
    select * from {{ ref('ttc_bus_delays') }}
),

standardized as (
    select
        -- Primary identifiers
        row_number() over (order by date, time, route, location) as delay_id,
        
        -- Temporal columns
        date as delay_date,
        time as delay_time,
        to_timestamp(date || ' ' || time, 'YYYY-MM-DD HH24:MI') as delay_datetime,
        day as day_of_week,
        extract(year from date) as delay_year,
        extract(month from date) as delay_month,
        extract(day from date) as delay_day,
        extract(hour from to_timestamp(time, 'HH24:MI')) as delay_hour,
        case 
            when day in ('Saturday', 'Sunday') then true
            else false
        end as is_weekend,
        
        -- Route/Location
        cast(route as varchar) as route_id,
        location,
        direction,
        
        -- Delay details
        incident as delay_cause,
        min_delay as delay_minutes,
        min_gap as gap_minutes,
        
        -- Vehicle info
        cast(vehicle as varchar) as vehicle_id,
        
        -- Metadata
        'bus' as transit_type,
        transit_type as original_transit_type,
        source_file,
        loaded_at,
        current_timestamp() as dbt_loaded_at
        
    from source
    where date is not null
)

select * from standardized

