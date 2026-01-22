-- Test: Order timestamps should align with their session timestamps (order should come after session start)

with misaligned_orders as (
    select
        o.order_id,
        o.website_session_id,
        o.order_created_at as order_timestamp,
        s.session_start_at as session_timestamp,
        extract(epoch from (o.order_created_at - s.session_start_at)) as seconds_difference
    from {{ ref('fact_orders') }} o
    join {{ ref('fact_sessions') }} s
        on o.website_session_id = s.website_session_id
    where o.order_created_at < s.session_start_at
)

select * from misaligned_orders
