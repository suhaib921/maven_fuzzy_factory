-- Test: Total refund amounts should match between fact_orders and fact_refunds

with order_refunds as (
    select
        sum(total_refund_amount_usd) as total_from_orders
    from {{ ref('fact_orders') }}
),

refund_table_totals as (
    select
        sum(refund_amount_usd) as total_from_refunds
    from {{ ref('fact_refunds') }}
)

select
    o.total_from_orders,
    r.total_from_refunds,
    abs(o.total_from_orders - r.total_from_refunds) as difference
from order_refunds o
cross join refund_table_totals r
where abs(o.total_from_orders - r.total_from_refunds) > 0.01
