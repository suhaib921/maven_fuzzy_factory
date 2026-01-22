-- Test: All dates should be within expected dataset range (2012-03-19 to 2015-03-19)
-- Note: Refunds can occur up to 16 days after orders, so allow until 2015-04-05

with date_checks as (
    select 'website_sessions' as table_name, website_session_id as id, created_at
    from {{ source('raw', 'website_sessions') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-03-20'::timestamp

    union all

    select 'website_pageviews', website_pageview_id, created_at
    from {{ source('raw', 'website_pageviews') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-03-20'::timestamp

    union all

    select 'orders', order_id, created_at
    from {{ source('raw', 'orders') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-03-20'::timestamp

    union all

    select 'order_items', order_item_id, created_at
    from {{ source('raw', 'order_items') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-03-20'::timestamp

    union all

    -- Refunds can occur up to 16 days after the dataset end date
    select 'order_item_refunds', order_item_refund_id, created_at
    from {{ source('raw', 'order_item_refunds') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-04-05'::timestamp

    union all

    select 'products', product_id, created_at
    from {{ source('raw', 'products') }}
    where created_at < '2012-03-19'::timestamp or created_at > '2015-03-20'::timestamp
)

select * from date_checks
