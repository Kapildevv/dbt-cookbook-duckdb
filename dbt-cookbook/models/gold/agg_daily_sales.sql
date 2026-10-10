with orders as (

    select * from {{ ref('fct_orders') }}
    where order_status = 'Delivered'

)

select
    order_date,
    category,
    count(distinct order_id)        as orders_count,
    sum(quantity)                   as units_sold,
    sum(total_amount)               as gross_revenue,
    sum(gst_amount)                 as gst_collected,
    sum(coalesce(cashback_amount, 0)) as cashback_paid
from orders
group by order_date, category
