{#
    The grain of the warehouse: one row per order line, with everything a
    report needs already joined. Gold reads from SILVER only -- never from
    bronze, never from a source. That rule is what makes the layers mean
    something.
#}

with orders as (

    select * from {{ ref('silver_transactions') }}

),

customers as (

    select * from {{ ref('silver_customers') }}

),

products as (

    select * from {{ ref('silver_products') }}

),

payments as (

    select * from {{ ref('silver_payments') }}

),

cashback as (

    select * from {{ ref('silver_cashback') }}

)

select
    o.order_id,
    o.ordered_at,
    o.order_date,
    o.order_status,
    o.order_status_code,

    o.customer_id,
    c.full_name                 as customer_name,
    c.city,
    c.address_state,

    o.product_id,
    p.product_name,
    p.category,
    p.brand,

    o.quantity,
    o.unit_price,
    o.total_amount,
    o.gst_amount,

    pay.payment_method,
    pay.gateway_name,
    pay.payment_status,
    pay.processing_fee,

    -- Left joined: most orders have no cashback, and an inner join here
    -- would silently drop half the warehouse.
    cb.cashback_amount,
    cb.cashback_status
from orders as o
left join customers as c on o.customer_id = c.customer_id
left join products  as p on o.product_id  = p.product_id
left join payments  as pay on o.order_id  = pay.order_id
left join cashback  as cb on o.order_id   = cb.order_id
