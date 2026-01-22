{{
    config(
        materialized='table',
        schema='aggregate'
    )
}}

-- Funnel conversion metrics for optimization analysis
-- Pre-aggregates conversion rates at each funnel step

with funnel_summary as (
    select
        -- Overall funnel metrics
        count(distinct website_session_id) as total_sessions,
        count(distinct case when reached_products then website_session_id end) as reached_products,
        count(distinct case when reached_cart then website_session_id end) as reached_cart,
        count(distinct case when reached_shipping then website_session_id end) as reached_shipping,
        count(distinct case when reached_billing then website_session_id end) as reached_billing,
        count(distinct case when reached_thank_you then website_session_id end) as reached_thank_you,
        count(distinct case when has_order then website_session_id end) as completed_orders,

        -- Conversion rates (from total sessions)
        round(100.0 * count(distinct case when reached_products then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as cvr_to_products,
        round(100.0 * count(distinct case when reached_cart then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as cvr_to_cart,
        round(100.0 * count(distinct case when reached_shipping then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as cvr_to_shipping,
        round(100.0 * count(distinct case when reached_billing then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as cvr_to_billing,
        round(100.0 * count(distinct case when reached_thank_you then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as cvr_to_thank_you,
        round(100.0 * count(distinct case when has_order then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as overall_conversion_rate,

        -- Step-by-step conversion rates (from previous step)
        round(100.0 * count(distinct case when reached_cart then website_session_id end) /
              nullif(count(distinct case when reached_products then website_session_id end), 0), 2) as cvr_products_to_cart,
        round(100.0 * count(distinct case when reached_shipping then website_session_id end) /
              nullif(count(distinct case when reached_cart then website_session_id end), 0), 2) as cvr_cart_to_shipping,
        round(100.0 * count(distinct case when reached_billing then website_session_id end) /
              nullif(count(distinct case when reached_shipping then website_session_id end), 0), 2) as cvr_shipping_to_billing,
        round(100.0 * count(distinct case when reached_thank_you then website_session_id end) /
              nullif(count(distinct case when reached_billing then website_session_id end), 0), 2) as cvr_billing_to_thank_you,

        -- Drop-off counts
        count(distinct case when not reached_products then website_session_id end) as dropped_before_products,
        count(distinct case when reached_products and not reached_cart then website_session_id end) as dropped_at_products,
        count(distinct case when reached_cart and not reached_shipping then website_session_id end) as dropped_at_cart,
        count(distinct case when reached_shipping and not reached_billing then website_session_id end) as dropped_at_shipping,
        count(distinct case when reached_billing and not reached_thank_you then website_session_id end) as dropped_at_billing,

        -- Drop-off rates
        round(100.0 * count(distinct case when not reached_products then website_session_id end) /
              nullif(count(distinct website_session_id), 0), 2) as dropoff_rate_before_products,
        round(100.0 * count(distinct case when reached_products and not reached_cart then website_session_id end) /
              nullif(count(distinct case when reached_products then website_session_id end), 0), 2) as dropoff_rate_at_products,
        round(100.0 * count(distinct case when reached_cart and not reached_shipping then website_session_id end) /
              nullif(count(distinct case when reached_cart then website_session_id end), 0), 2) as dropoff_rate_at_cart,
        round(100.0 * count(distinct case when reached_shipping and not reached_billing then website_session_id end) /
              nullif(count(distinct case when reached_shipping then website_session_id end), 0), 2) as dropoff_rate_at_shipping,
        round(100.0 * count(distinct case when reached_billing and not reached_thank_you then website_session_id end) /
              nullif(count(distinct case when reached_billing then website_session_id end), 0), 2) as dropoff_rate_at_billing

    from {{ ref('fact_sessions') }}
),

funnel_by_channel as (
    select
        c.channel_name,
        c.campaign_type,
        dev.device_type,

        count(distinct s.website_session_id) as total_sessions,
        count(distinct case when s.reached_products then s.website_session_id end) as reached_products,
        count(distinct case when s.reached_cart then s.website_session_id end) as reached_cart,
        count(distinct case when s.reached_billing then s.website_session_id end) as reached_billing,
        count(distinct case when s.has_order then s.website_session_id end) as completed_orders,

        round(100.0 * count(distinct case when s.reached_products then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as cvr_to_products,
        round(100.0 * count(distinct case when s.reached_cart then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as cvr_to_cart,
        round(100.0 * count(distinct case when s.has_order then s.website_session_id end) /
              nullif(count(distinct s.website_session_id), 0), 2) as overall_conversion_rate

    from {{ ref('fact_sessions') }} s
    join {{ ref('dim_channel') }} c on s.channel_key = c.channel_key
    join {{ ref('dim_device') }} dev on s.device_key = dev.device_key
    group by c.channel_name, c.campaign_type, dev.device_type
)

-- Combine overall and by-channel funnels
select
    'Overall' as segment_type,
    'All Traffic' as segment_name,
    null as device_type,
    total_sessions,
    reached_products,
    reached_cart,
    reached_shipping,
    reached_billing,
    reached_thank_you,
    completed_orders,
    cvr_to_products,
    cvr_to_cart,
    cvr_to_shipping,
    cvr_to_billing,
    cvr_to_thank_you,
    overall_conversion_rate,
    cvr_products_to_cart,
    cvr_cart_to_shipping,
    cvr_shipping_to_billing,
    cvr_billing_to_thank_you,
    dropped_before_products,
    dropped_at_products,
    dropped_at_cart,
    dropped_at_shipping,
    dropped_at_billing,
    dropoff_rate_before_products,
    dropoff_rate_at_products,
    dropoff_rate_at_cart,
    dropoff_rate_at_shipping,
    dropoff_rate_at_billing
from funnel_summary

union all

select
    'Channel' as segment_type,
    channel_name as segment_name,
    device_type,
    total_sessions,
    reached_products,
    reached_cart,
    null as reached_shipping,
    reached_billing,
    null as reached_thank_you,
    completed_orders,
    cvr_to_products,
    cvr_to_cart,
    null as cvr_to_shipping,
    null as cvr_to_billing,
    null as cvr_to_thank_you,
    overall_conversion_rate,
    null as cvr_products_to_cart,
    null as cvr_cart_to_shipping,
    null as cvr_shipping_to_billing,
    null as cvr_billing_to_thank_you,
    null as dropped_before_products,
    null as dropped_at_products,
    null as dropped_at_cart,
    null as dropped_at_shipping,
    null as dropped_at_billing,
    null as dropoff_rate_before_products,
    null as dropoff_rate_at_products,
    null as dropoff_rate_at_cart,
    null as dropoff_rate_at_shipping,
    null as dropoff_rate_at_billing
from funnel_by_channel

order by segment_type, total_sessions desc
