with source as (

    select * from {{ ref('bronze_pg_data') }}

),

flattened as (

    select
        payment_id,
        order_id,
        payment_method,
        gateway_name,
        payment_status,
        {{ json_field('pg_metadata', 'bank_reference_no') }} as bank_reference_no,
        {{ json_field('pg_metadata', 'error_code') }}        as error_code,
        cast({{ json_field('pg_metadata', 'processing_fee_inr') }}
             as decimal(12, 2))                              as processing_fee,
        {{ json_field('pg_metadata', 'merchant_vpa') }}      as merchant_vpa,
        {{ json_field('pg_metadata', 'ip_address') }}        as ip_address
    from source

)

select * from flattened
