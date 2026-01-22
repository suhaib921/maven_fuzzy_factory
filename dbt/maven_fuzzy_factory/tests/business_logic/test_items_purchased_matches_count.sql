-- Test: orders.items_purchased should equal count of order_items per order

with order_item_counts as (
    select
        order_id,
        count(*) as actual_item_count
    from {{ source('raw', 'order_items') }}
    group by order_id
),

orders_with_counts as (
    select
        o.order_id,
        o.items_purchased as expected_count,
        coalesce(i.actual_item_count, 0) as actual_count
    from {{ source('raw', 'orders') }} o
    left join order_item_counts i on o.order_id = i.order_id
)

select
    order_id,
    expected_count,
    actual_count
from orders_with_counts
where expected_count != actual_count
