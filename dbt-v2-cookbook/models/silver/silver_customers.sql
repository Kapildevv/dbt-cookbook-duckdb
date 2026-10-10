with source as (

    select * from {{ ref('bronze_customers') }}

),

deduplicated as (

    -- The source re-sends a whole row when a field is corrected, so the
    -- same customer_id arrives twice. Keep one row per id, preferring the
    -- corrected email. The order by must be deterministic or the winner
    -- changes between runs.
    select
        *,
        row_number() over (
            partition by customer_id
            order by nullif(trim(email), '') nulls last, email
        ) as _row_num
    from source

),

flattened as (

    select
        customer_id,
        trim(first_name)                                as first_name,
        trim(last_name)                                 as last_name,
        trim(first_name) || ' ' || trim(last_name)      as full_name,
        lower(nullif(trim(email), ''))                  as email,
        phone_number,
        cast(registration_date as date)                 as registration_date,

        -- JSON arrives as text. Pull out the fields the business asks for
        -- and leave the rest in the column for later.
        {{ json_field('customer_metadata', 'device_type') }}  as device_type,
        {{ json_field('customer_metadata', 'city') }}         as city,
        {{ json_field('customer_metadata', 'address_state') }} as address_state,
        {{ json_field('customer_metadata', 'address.pincode') }} as pincode,
        {{ json_field('customer_metadata', 'app_version') }}  as app_version,
        {{ json_field('customer_metadata', 'locale') }}       as locale
    from deduplicated
    where _row_num = 1

)

select * from flattened
