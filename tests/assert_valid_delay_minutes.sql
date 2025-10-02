-- Check delay minutes are in reasonable range

select
    delay_id,
    delay_minutes,
    transit_type
from {{ ref('stg_ttc_all_delays') }}
where delay_minutes < 0 or delay_minutes > 500
