-- An analysis is compiled by dbt but never executed or materialised.
-- `dbt compile` writes the SQL to target/compiled/ for you to read or paste
-- into a query tool. It is the best place to learn what Jinja actually does.

{% set reporting_columns = ['order_id', 'order_status', 'total_amount'] %}
{% set minimum_value = 500 %}

select
    {% for column in reporting_columns %}
    {{ column }}{% if not loop.last %},{% endif %}
    {% endfor %}

from {{ ref('silver_transactions') }}

{% if minimum_value %}
where total_amount >= {{ minimum_value }}
{% endif %}

order by total_amount desc
