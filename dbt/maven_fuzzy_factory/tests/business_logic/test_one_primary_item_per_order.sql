-- Test: Each order should have exactly one primary item (is_primary_item = 1)

with primary_item_counts as (
    select
        order_id,
        sum(is_primary_item) as primary_item_count
    from {{ source('raw', 'order_items') }}
    group by order_id
)

select
    order_id,
    primary_item_count
from primary_item_counts
where primary_item_count != 1
