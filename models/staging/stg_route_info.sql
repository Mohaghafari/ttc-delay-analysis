{{
    config(
        materialized='view',
        tags=['staging', 'reference']
    )
}}

with source as (
    select * from {{ ref('route_info') }}
),

renamed as (
    select
        route_id,
        route_name,
        route_type,
        avg_fare,
        is_active,
        created_at as source_created_at,
        current_timestamp() as dbt_loaded_at
        
    from source
)

select * from renamed

