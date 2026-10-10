{{
    config(
        materialized = 'incremental',
        unique_key   = 'order_id',
        incremental_strategy = 'delete+insert',
    )
}}

with source as (

    select * from {{ ref('bronze_transactions') }}

    {% if is_incremental() %}
    -- Re-read a window behind the watermark, not just past it. The
    -- storefront's offline queue can flush days late, and `>` alone
    -- drops those rows without reporting anything. The unique_key
    -- makes re-reading safe: a row seen twice is replaced, not doubled.
    where cast(order_date as timestamp) > (
        select max(ordered_at) - interval {{ var('lookback_days', 3) }} day
        from {{ this }}
    )
    {% endif %}

),

status_map as (

    select * from {{ ref('mapping') }}

),

typed as (

    select
        t.order_id,
        t.customer_id,
        t.product_id,
        cast(t.order_date as timestamp)             as ordered_at,
        cast(substr(t.order_date, 1, 10) as date)   as order_date,
        cast(t.quantity as integer)                 as quantity,
        cast(t.total_amount as decimal(12, 2))      as total_amount,
        t.order_status,
        cast(m.status_code as integer)              as order_status_code,

        -- 18% GST, via the macro, so the rate lives in one place.
        cast({{ multiply('cast(t.total_amount as decimal(12,2))', 0.18) }}
             as decimal(12, 2))                     as gst_amount,
        cast(t.total_amount as decimal(12, 2))
            / cast(t.quantity as integer)           as unit_price
    from source as t
    left join status_map as m
        on t.order_status = m.status_text

)

select * from typed
