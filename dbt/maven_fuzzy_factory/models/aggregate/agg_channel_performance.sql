{{
    config(
        materialized='table',
        schema='aggregate'
    )
}}

-- Channel performance aggregation for marketing analysis
-- Pre-aggregates metrics by marketing channel (source, campaign, device)

with channel_metrics as (
    select
        -- Channel dimensions
        c.channel_key,
        c.utm_source,
        c.utm_campaign,
        c.utm_content,
        c.source_normalized,
        c.channel_name,
        c.channel_category,
        c.is_paid_traffic,
        c.is_brand_campaign,
        c.is_nonbrand_campaign,
        c.campaign_type,

        -- Device dimension
        dev.device_type,

        -- Session metrics
        count(distinct s.website_session_id) as total_sessions,
        sum(s.pageview_count) as total_pageviews,
        round(avg(s.pageview_count), 2) as avg_pageviews_per_session,
        round(avg(s.session_duration_sec), 2) as avg_session_duration_sec,

        -- Bounce metrics
        count(distinct case when s.pageview_count = 1 then s.website_session_id end) as bounced_sessions,
        round(100.0 * count(distinct case when s.pageview_count = 1 then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as bounce_rate,

        -- Funnel metrics
        count(distinct case when s.reached_products then s.website_session_id end) as sessions_reached_products,
        count(distinct case when s.reached_cart then s.website_session_id end) as sessions_reached_cart,
        count(distinct case when s.reached_billing then s.website_session_id end) as sessions_reached_billing,
        count(distinct case when s.reached_thank_you then s.website_session_id end) as sessions_reached_thank_you,

        -- Order metrics
        count(distinct case when s.has_order then s.website_session_id end) as sessions_with_orders,
        count(distinct o.order_id) as total_orders,
        sum(o.items_purchased) as total_items_purchased,

        -- Revenue metrics
        coalesce(sum(o.gross_revenue_usd), 0) as gross_revenue,
        coalesce(sum(o.total_refund_amount_usd), 0) as total_refunds,
        coalesce(sum(o.net_revenue_usd), 0) as net_revenue,
        coalesce(sum(o.total_cogs_usd), 0) as total_cogs,
        coalesce(sum(o.gross_margin_usd), 0) as gross_margin,
        coalesce(sum(o.net_margin_usd), 0) as net_margin,

        -- Conversion metrics
        round(100.0 * count(distinct case when s.has_order then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as conversion_rate,
        round(100.0 * count(distinct case when s.reached_products then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as pct_reached_products,
        round(100.0 * count(distinct case when s.reached_cart then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as pct_reached_cart,

        -- Per-session metrics
        round(coalesce(sum(o.gross_revenue_usd), 0) /
              nullif(count(distinct s.website_session_id), 0), 2) as revenue_per_session,
        round(coalesce(sum(o.gross_revenue_usd), 0) /
              nullif(count(distinct o.order_id), 0), 2) as revenue_per_order,
        round(coalesce(sum(o.gross_margin_usd), 0) /
              nullif(count(distinct s.website_session_id), 0), 2) as margin_per_session,
        round(coalesce(sum(o.items_purchased), 0)::numeric /
              nullif(count(distinct o.order_id), 0), 2) as items_per_order,

        -- Refund metrics
        count(distinct case when o.has_refund then o.order_id end) as orders_with_refunds,
        round(100.0 * count(distinct case when o.has_refund then o.order_id end) /
              nullif(count(distinct o.order_id), 0), 2) as refund_rate

    from {{ ref('fact_sessions') }} s
    join {{ ref('dim_channel') }} c
        on s.channel_key = c.channel_key
    join {{ ref('dim_device') }} dev
        on s.device_key = dev.device_key
    left join {{ ref('fact_orders') }} o
        on s.website_session_id = o.website_session_id
    group by
        c.channel_key, c.utm_source, c.utm_campaign, c.utm_content,
        c.source_normalized, c.channel_name, c.channel_category,
        c.is_paid_traffic, c.is_brand_campaign, c.is_nonbrand_campaign,
        c.campaign_type, dev.device_type
)

select * from channel_metrics
order by total_sessions desc
