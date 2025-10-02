{{
    config(
        materialized='incremental',
        unique_key='trip_id',
        on_schema_change='append_new_columns',
        cluster_by=['trip_date'],
        tags=['incremental', 'trips']
    )
}}

with trips as (
    select * from {{ ref('int_trips_enriched') }}
    
    {% if is_incremental() %}
    -- Only process new records since last run
    where trip_datetime > (select max(trip_datetime) from {{ this }})
    {% endif %}
),

final as (
    select
        trip_id,
        trip_datetime,
        trip_date,
        trip_year,
        trip_month,
        trip_day,
        trip_hour,
        day_of_week,
        is_weekend,
        time_period,
        
        route_id,
        route_name,
        route_type,
        
        passengers,
        payment_type,
        fare_amount,
        trip_revenue,
        
        boarding_status,
        delay_category,
        delay_minutes,
        
        is_fare_evasion,
        
        vehicle_id,
        stop_sequence,
        temperature_celsius,
        
        dbt_loaded_at,
        current_timestamp() as dbt_updated_at
        
    from trips
)

select * from final

