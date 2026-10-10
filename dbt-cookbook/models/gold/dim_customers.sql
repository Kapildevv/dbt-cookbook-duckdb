with customers as (

    select * from {{ ref('silver_customers') }}

),

orders as (

    select * from {{ ref('silver_transactions') }}
    where order_status = 'Delivered'

),

per_customer as (

    select
        customer_id,
        count(*)                as delivered_orders,
        sum(total_amount)       as lifetime_value,
        min(order_date)         as first_order_date,
        max(order_date)         as most_recent_order_date
    from orders
    group by customer_id

)

select
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.address_state,
    c.device_type,
    c.registration_date,
    coalesce(p.delivered_orders, 0)     as delivered_orders,
    coalesce(p.lifetime_value, 0)       as lifetime_value,
    p.first_order_date,
    p.most_recent_order_date,
    case
        when coalesce(p.delivered_orders, 0) = 0 then 'prospect'
        when p.delivered_orders = 1              then 'new'
        when p.delivered_orders < 5              then 'repeat'
        else 'loyal'
    end                                 as customer_segment
from customers as c
left join per_customer as p
    on c.customer_id = p.customer_id
