-- Test: All prices and COGS should be positive (> 0)

with price_checks as (
    select 'orders' as table_name, order_id as id, 'price_usd' as column_name, price_usd as value
    from {{ source('raw', 'orders') }}
    where price_usd <= 0

    union all

    select 'orders', order_id, 'cogs_usd', cogs_usd
    from {{ source('raw', 'orders') }}
    where cogs_usd <= 0

    union all

    select 'order_items', order_item_id, 'price_usd', price_usd
    from {{ source('raw', 'order_items') }}
    where price_usd <= 0

    union all

    select 'order_items', order_item_id, 'cogs_usd', cogs_usd
    from {{ source('raw', 'order_items') }}
    where cogs_usd <= 0

    union all

    select 'order_item_refunds', order_item_refund_id, 'refund_amount_usd', refund_amount_usd
    from {{ source('raw', 'order_item_refunds') }}
    where refund_amount_usd <= 0
)

select * from price_checks
