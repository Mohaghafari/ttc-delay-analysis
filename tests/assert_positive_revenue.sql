-- This test ensures that the total revenue is positive
-- for routes that had trips

select
    route_id,
    route_name,
    sum(total_revenue) as total_revenue
from {{ ref('fct_daily_route_performance') }}
group by 1, 2
having sum(total_revenue) < 0

