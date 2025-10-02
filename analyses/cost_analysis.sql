-- Cost Analysis: Clustering Impact
-- This analysis demonstrates the cost savings from clustering

with clustered_query as (
    -- Query using clustering keys (efficient)
    select
        trip_date,
        route_id,
        count(*) as trip_count,
        sum(passengers) as total_passengers
    from {{ ref('fct_daily_route_performance') }}
    where trip_date between '2024-01-01' and '2024-01-31'
        and route_id in (1, 2, 5)
    group by 1, 2
)

select
    'Leverages clustering on trip_date and route_id' as optimization_note,
    count(*) as result_count
from clustered_query

