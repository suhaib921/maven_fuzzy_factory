-- Test: Row counts should match between raw, staging, and mart layers

with layer_counts as (
    select 'sessions' as entity, 'raw' as layer, count(*) as row_count
    from {{ source('raw', 'website_sessions') }}

    union all

    select 'sessions', 'staging', count(*)
    from {{ ref('stg_website_sessions') }}

    union all

    select 'sessions', 'mart', count(*)
    from {{ ref('fact_sessions') }}

    union all

    select 'pageviews', 'raw', count(*)
    from {{ source('raw', 'website_pageviews') }}

    union all

    select 'pageviews', 'staging', count(*)
    from {{ ref('stg_website_pageviews') }}

    union all

    select 'pageviews', 'mart', count(*)
    from {{ ref('fact_pageviews') }}

    union all

    select 'orders', 'raw', count(*)
    from {{ source('raw', 'orders') }}

    union all

    select 'orders', 'staging', count(*)
    from {{ ref('stg_orders') }}

    union all

    select 'orders', 'mart', count(*)
    from {{ ref('fact_orders') }}
),

counts_by_entity as (
    select
        entity,
        max(case when layer = 'raw' then row_count end) as raw_count,
        max(case when layer = 'staging' then row_count end) as staging_count,
        max(case when layer = 'mart' then row_count end) as mart_count
    from layer_counts
    group by entity
)

select
    entity,
    raw_count,
    staging_count,
    mart_count
from counts_by_entity
where raw_count != staging_count
   or raw_count != mart_count
   or staging_count != mart_count
