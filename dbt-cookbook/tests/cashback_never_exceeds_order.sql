-- Cashback should never be more than the order it is paid against.
select
    order_id,
    total_amount,
    cashback_amount
from {{ ref('fct_orders') }}
where cashback_amount > total_amount
