{{
    config(
        materialized='table',
        schema='aggregate'
    )
}}

-- Daily traffic aggregation for dashboard performance
-- Pre-aggregates sessions, orders, pageviews, and conversion metrics by date

with daily_metrics as (
    select
        d.date as date,
        d.year,
        d.quarter,
        d.month_of_year as month,
        d.month_name,
        d.day_of_week,
        d.day_of_week_name as day_name,
        d.is_weekend,

        -- Session metrics
        count(distinct s.website_session_id) as total_sessions,

        -- Pageview metrics
        sum(s.pageview_count) as total_pageviews,
        round(avg(s.pageview_count), 2) as avg_pageviews_per_session,

        -- Bounce metrics
        count(distinct case when s.pageview_count = 1 then s.website_session_id end) as bounced_sessions,

        -- Order metrics
        count(distinct case when s.has_order then s.website_session_id end) as sessions_with_orders,
        count(distinct o.order_id) as total_orders,
        sum(o.items_purchased) as total_items_purchased,

        -- Revenue metrics
        coalesce(sum(o.gross_revenue_usd), 0) as gross_revenue,
        coalesce(sum(o.total_refund_amount_usd), 0) as total_refunds,
        coalesce(sum(o.net_revenue_usd), 0) as net_revenue,
        coalesce(sum(o.gross_margin_usd), 0) as gross_margin,
        coalesce(sum(o.net_margin_usd), 0) as net_margin,

        -- Calculated metrics
        round(100.0 * count(distinct case when s.has_order then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as conversion_rate,
        round(100.0 * count(distinct case when s.pageview_count = 1 then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as bounce_rate,
        round(coalesce(sum(o.gross_revenue_usd), 0) /
              nullif(count(distinct s.website_session_id), 0), 2) as revenue_per_session,
        round(coalesce(sum(o.gross_revenue_usd), 0) /
              nullif(count(distinct o.order_id), 0), 2) as revenue_per_order,
        round(coalesce(sum(o.items_purchased), 0)::numeric /
              nullif(count(distinct o.order_id), 0), 2) as items_per_order,

        -- Refund metrics
        count(distinct case when o.has_refund then o.order_id end) as orders_with_refunds,
        round(100.0 * count(distinct case when o.has_refund then o.order_id end) /
              nullif(count(distinct o.order_id), 0), 2) as refund_rate

    from {{ ref('dim_date') }} d
    left join {{ ref('fact_sessions') }} s
        on d.date = s.date_key::date
    left join {{ ref('fact_orders') }} o
        on s.website_session_id = o.website_session_id
    where d.date between '2012-03-19' and '2015-03-19'
    group by
        d.date, d.year, d.quarter, d.month_of_year, d.month_name,
        d.day_of_week, d.day_of_week_name, d.is_weekend
)

select * from daily_metrics
order by date
