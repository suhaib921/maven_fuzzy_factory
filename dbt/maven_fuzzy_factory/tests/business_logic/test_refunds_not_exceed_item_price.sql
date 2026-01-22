-- Test: Refund amounts should not exceed original order item prices

with refund_checks as (
    select
        r.order_item_refund_id,
        r.order_item_id,
        r.refund_amount_usd,
        oi.price_usd as item_price,
        r.refund_amount_usd - oi.price_usd as excess_refund
    from {{ source('raw', 'order_item_refunds') }} r
    join {{ source('raw', 'order_items') }} oi
        on r.order_item_id = oi.order_item_id
)

select
    order_item_refund_id,
    order_item_id,
    refund_amount_usd,
    item_price,
    excess_refund
from refund_checks
where refund_amount_usd > item_price
