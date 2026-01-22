-- Test: Overall conversion rate should be between 2% and 15% (reasonable e-commerce range)

with metrics as (
    select
        count(distinct s.website_session_id) as total_sessions,
        count(distinct o.order_id) as total_orders,
        (count(distinct o.order_id)::numeric / count(distinct s.website_session_id)::numeric) * 100 as conversion_rate
    from {{ source('raw', 'website_sessions') }} s
    left join {{ source('raw', 'orders') }} o
        on s.website_session_id = o.website_session_id
)

select
    total_sessions,
    total_orders,
    conversion_rate
from metrics
where conversion_rate < 2.0 or conversion_rate > 15.0
