with source as (

    select * from {{ ref('bronze_cashback_rewards') }}

)

select
    reward_id,
    order_id,
    cast(cashback_amount as decimal(12, 2))         as cashback_amount,
    cast(substr(crediting_date, 1, 10) as date)     as cashback_date,
    status                                          as cashback_status
from source
