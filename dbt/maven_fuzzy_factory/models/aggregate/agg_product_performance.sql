{{
    config(
        materialized='table',
        schema='aggregate'
    )
}}

-- Product performance aggregation for product analysis
-- Pre-aggregates sales, revenue, and refund metrics by product

with product_metrics as (
    select
        -- Product dimensions
        p.product_key,
        p.product_id,
        p.product_name,
        p.product_category,
        p.product_line,
        p.is_original_product,
        p.is_mini_product,
        p.product_launch_date as launch_date,
        p.launch_sequence,

        -- Order item metrics
        count(distinct oi.order_item_id) as total_items_sold,
        count(distinct oi.order_id) as total_orders,
        count(distinct oi.website_session_id) as total_sessions,
        count(distinct oi.user_id) as unique_customers,

        -- Primary vs cross-sell metrics (checking if product matches order's primary product)
        count(distinct case when o.product_key = p.product_key then oi.order_item_id end) as items_as_primary,
        count(distinct case when o.product_key != p.product_key then oi.order_item_id end) as items_as_cross_sell,
        round(100.0 * count(distinct case when o.product_key = p.product_key then oi.order_item_id end) /
              nullif(count(distinct oi.order_item_id), 0), 2) as pct_sold_as_primary,

        -- Revenue metrics
        sum(oi.item_price_usd) as gross_revenue,
        sum(oi.item_cogs_usd) as total_cogs,
        sum(oi.item_margin_usd) as gross_margin,
        round(100.0 * sum(oi.item_margin_usd) /
              nullif(sum(oi.item_price_usd), 0), 2) as margin_percentage,

        -- Refund metrics
        count(distinct case when oi.is_refunded then oi.order_item_id end) as items_refunded,
        sum(oi.refund_amount_usd) as total_refund_amount,
        sum(oi.net_item_revenue_usd) as net_revenue,
        sum(oi.net_item_margin_usd) as net_margin,
        round(100.0 * count(distinct case when oi.is_refunded then oi.order_item_id end) /
              nullif(count(distinct oi.order_item_id), 0), 2) as refund_rate,

        -- Average metrics
        round(avg(oi.item_price_usd), 2) as avg_price_per_item,
        round(avg(oi.item_cogs_usd), 2) as avg_cogs_per_item,
        round(avg(oi.item_margin_usd), 2) as avg_margin_per_item,
        round(avg(case when oi.is_refunded then oi.days_to_refund end), 2) as avg_days_to_refund,

        -- Date range
        min(oi.order_item_created_at) as first_sale_date,
        max(oi.order_item_created_at) as last_sale_date,
        extract(day from max(oi.order_item_created_at) - min(oi.order_item_created_at)) as days_on_market

    from {{ ref('fact_order_items') }} oi
    join {{ ref('dim_product') }} p
        on oi.product_key = p.product_key
    join {{ ref('fact_orders') }} o
        on oi.order_id = o.order_id
    group by
        p.product_key, p.product_id, p.product_name, p.product_category,
        p.product_line, p.is_original_product, p.is_mini_product,
        p.product_launch_date, p.launch_sequence
)

select * from product_metrics
order by gross_revenue desc
