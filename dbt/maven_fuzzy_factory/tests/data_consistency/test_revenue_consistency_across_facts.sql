-- Test: Revenue totals should match between fact_orders and fact_order_items

with order_revenue as (
    select
        sum(gross_revenue_usd) as total_order_revenue,
        sum(total_cogs_usd) as total_order_cogs,
        sum(gross_margin_usd) as total_order_margin
    from {{ ref('fact_orders') }}
),

item_revenue as (
    select
        sum(item_price_usd) as total_item_revenue,
        sum(item_cogs_usd) as total_item_cogs,
        sum(item_margin_usd) as total_item_margin
    from {{ ref('fact_order_items') }}
)

select
    o.total_order_revenue,
    i.total_item_revenue,
    abs(o.total_order_revenue - i.total_item_revenue) as revenue_diff,
    o.total_order_cogs,
    i.total_item_cogs,
    abs(o.total_order_cogs - i.total_item_cogs) as cogs_diff,
    o.total_order_margin,
    i.total_item_margin,
    abs(o.total_order_margin - i.total_item_margin) as margin_diff
from order_revenue o
cross join item_revenue i
where abs(o.total_order_revenue - i.total_item_revenue) > 0.01
   or abs(o.total_order_cogs - i.total_item_cogs) > 0.01
   or abs(o.total_order_margin - i.total_item_margin) > 0.01
