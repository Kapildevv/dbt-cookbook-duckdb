select
    *
from
    {{ source('raw', 'pg_data') }}
