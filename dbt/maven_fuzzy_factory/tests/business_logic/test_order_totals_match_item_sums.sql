-- Test: Order price_usd should equal sum of order_items price_usd
-- Tolerance: Allow $0.01 rounding difference

with order_totals as (
    select
        order_id,
        price_usd as order_price
    from {{ source('raw', 'orders') }}
),

item_totals as (
    select
        order_id,
        sum(price_usd) as items_total_price
    from {{ source('raw', 'order_items') }}
    group by order_id
)

select
    o.order_id,
    o.order_price,
    i.items_total_price,
    abs(o.order_price - i.items_total_price) as price_difference
from order_totals o
join item_totals i on o.order_id = i.order_id
where abs(o.order_price - i.items_total_price) > 0.01
