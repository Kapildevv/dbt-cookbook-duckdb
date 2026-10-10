with source as (

    select * from {{ ref('bronze_products') }}

),

flattened as (

    select
        product_id,
        trim(product_name)                                  as product_name,
        trim(category)                                      as category,
        trim(brand)                                         as brand,
        cast(base_price as decimal(12, 2))                  as base_price,

        cast({{ json_field('product_specs', 'weight_grams') }} as integer)
            as weight_grams,
        cast({{ json_field('product_specs', 'warranty_months') }} as integer)
            as warranty_months,
        cast({{ json_field('product_specs', 'is_returnable') }} as boolean)
            as is_returnable,
        {{ json_field('product_specs', 'model_code') }}     as model_code
    from source

)

select * from flattened
