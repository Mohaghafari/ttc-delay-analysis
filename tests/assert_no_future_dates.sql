-- This test ensures no trips are recorded in the future

select
    trip_id,
    trip_datetime
from {{ ref('stg_ttc_trips') }}
where trip_datetime > current_timestamp()

