select
    *
from
    {{ source('raw', 'cashback_rewards') }}
