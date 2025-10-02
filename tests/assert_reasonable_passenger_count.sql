-- This test checks for anomalous passenger counts
-- Maximum capacity for TTC vehicles is ~200

select
    trip_id,
    passengers,
    route_type
from {{ ref('stg_ttc_trips') }}
where passengers > 200 or passengers < 0

