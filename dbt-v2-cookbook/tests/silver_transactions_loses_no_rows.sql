-- Silver transactions casts and maps; it does not filter. Every bronze
-- row must arrive. This is the test that catches an incremental model
-- silently dropping a late row -- no generic test will, because every
-- row that IS present is valid.
with bronze as (
    select count(*) as n from {{ ref('bronze_transactions') }}
),
silver as (
    select count(*) as n from {{ ref('silver_transactions') }}
)
select
    bronze.n as bronze_rows,
    silver.n as silver_rows
from bronze, silver
where bronze.n != silver.n
