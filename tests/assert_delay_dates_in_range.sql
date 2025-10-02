-- Check dates are within expected range

select
    delay_id,
    delay_date,
    transit_type
from {{ ref('stg_ttc_all_delays') }}
where delay_date < '2022-01-01' or delay_date > current_date()
