-- Test: Pageview timestamps should be >= their session start timestamp

with misaligned_timestamps as (
    select
        p.website_pageview_id,
        p.website_session_id,
        p.pageview_created_at as pageview_timestamp,
        s.session_start_at as session_timestamp,
        p.pageview_created_at - s.session_start_at as time_difference_sec
    from {{ ref('fact_pageviews') }} p
    join {{ ref('fact_sessions') }} s
        on p.website_session_id = s.website_session_id
    where p.pageview_created_at < s.session_start_at
)

select * from misaligned_timestamps
