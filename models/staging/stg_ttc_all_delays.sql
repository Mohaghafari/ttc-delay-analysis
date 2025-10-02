{{
    config(
        materialized='view',
        tags=['staging', 'delays', 'unified']
    )
}}

-- Combine all delay types into one unified view

with subway as (
    select
        delay_id,
        delay_datetime,
        delay_date,
        delay_time,
        delay_year,
        delay_month,
        delay_day,
        delay_hour,
        day_of_week,
        is_weekend,
        null as route_id,
        station as location,
        direction,
        delay_code as delay_cause,
        delay_minutes,
        gap_minutes,
        vehicle_id,
        'subway' as transit_type,
        line as line_route,
        dbt_loaded_at
    from {{ ref('stg_ttc_subway_delays') }}
),

bus as (
    select
        delay_id + 100000 as delay_id,  -- Offset to avoid conflicts
        delay_datetime,
        delay_date,
        delay_time,
        delay_year,
        delay_month,
        delay_day,
        delay_hour,
        day_of_week,
        is_weekend,
        route_id,
        location,
        direction,
        delay_cause,
        delay_minutes,
        gap_minutes,
        vehicle_id,
        'bus' as transit_type,
        route_id as line_route,
        dbt_loaded_at
    from {{ ref('stg_ttc_bus_delays') }}
),

streetcar as (
    select
        delay_id + 200000 as delay_id,  -- Offset to avoid conflicts
        delay_datetime,
        delay_date,
        delay_time,
        delay_year,
        delay_month,
        delay_day,
        delay_hour,
        day_of_week,
        is_weekend,
        route_id,
        location,
        direction,
        delay_cause,
        delay_minutes,
        gap_minutes,
        vehicle_id,
        'streetcar' as transit_type,
        route_id as line_route,
        dbt_loaded_at
    from {{ ref('stg_ttc_streetcar_delays') }}
),

combined as (
    select * from subway
    union all
    select * from bus
    union all
    select * from streetcar
)

select * from combined

