{#
    Month-on-month repeat behaviour, using a window function over the
    silver layer. The reference implementation of this pattern often reads
    straight from bronze; going through silver means the dates are already
    typed and the statuses already mapped.
#}

with monthly as (

    select distinct
        customer_id,
        date_trunc('month', order_date) as order_month
    from {{ ref('silver_transactions') }}
    where order_status = 'Delivered'

)

select
    customer_id,
    cast(order_month as date)   as order_month,
    cast(lag(order_month) over (
        partition by customer_id
        order by order_month
    ) as date)                  as previous_order_month,
    date_diff('month',
        lag(order_month) over (
            partition by customer_id order by order_month),
        order_month)            as months_since_previous
from monthly
