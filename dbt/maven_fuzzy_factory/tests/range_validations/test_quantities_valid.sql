-- Test: items_purchased should be >= 1

select
    order_id,
    items_purchased
from {{ source('raw', 'orders') }}
where items_purchased < 1
