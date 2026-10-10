{#
    A snapshot records history that the source does not keep. The payment
    gateway overwrites payment_status in place, so once a Failed payment
    is retried and succeeds, the fact that it ever failed is gone.

    check strategy, because pg_data carries no reliable updated_at.

    schema, not target_schema: target_schema is one fixed schema for every
    target, so a dev run would write into the same history as prod.
    hard_deletes='invalidate': a payment that vanishes from the feed stops
    looking current, and "dbt_valid_to is null" still means current.
    payment_id must be unique in this select or the snapshot doubles on
    every run; the unique test on silver_payments guards it under dbt build.
    The five columns are chosen on purpose: no ip_address in a history
    that can never be rebuilt.
#}
{% snapshot snap_payments %}

{{
    config(
        schema='snapshots',
        hard_deletes='invalidate',
        unique_key='payment_id',
        strategy='check',
        check_cols=['payment_status', 'error_code']
    )
}}

select
    payment_id,
    order_id,
    payment_status,
    error_code,
    processing_fee
from {{ ref('silver_payments') }}

{% endsnapshot %}
