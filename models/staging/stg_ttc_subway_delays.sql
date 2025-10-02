{{
    config(
        materialized='view',
        tags=['staging', 'delays', 'subway']
    )
}}

-- Clean and standardize subway delay data from raw seeds

with source as (
    select * from {{ ref('ttc_subway_delays') }}
),

standardized as (
    select
        row_number() over (order by date, time, station) as delay_id,
        
        -- Date/time fields
        date as delay_date,
        time as delay_time,
        to_timestamp(date || ' ' || time, 'YYYY-MM-DD HH24:MI') as delay_datetime,
        day as day_of_week,
        extract(year from date) as delay_year,
        extract(month from date) as delay_month,
        extract(day from date) as delay_day,
        extract(hour from to_timestamp(time, 'HH24:MI')) as delay_hour,
        case when day in ('Saturday', 'Sunday') then true else false end as is_weekend,
        
        -- Location info
        station,
        bound as direction,
        line,
        
        -- Delay details
        code as delay_code,
        min_delay as delay_minutes,
        min_gap as gap_minutes,
        vehicle as vehicle_id,
        
        -- Metadata
        'subway' as transit_type,
        transit_type as original_transit_type,
        source_file,
        loaded_at,
        current_timestamp() as dbt_loaded_at
        
    from source
    where date is not null  -- filter out bad records
)

select * from standardized

