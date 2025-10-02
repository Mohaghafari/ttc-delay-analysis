-- Check for duplicate delay IDs in the unified view

select
    delay_id,
    count(*) as occurrences
from {{ ref('stg_ttc_all_delays') }}
group by 1
having count(*) > 1
