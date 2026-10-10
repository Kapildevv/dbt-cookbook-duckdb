{#
    A custom generic test. dbt passes in the model and the column it is
    attached to; you return the rows that FAIL. No rows means a pass.
#}
{% test non_negative(model, column_name) %}

select
    *
from {{ model }}
where cast({{ column_name }} as double) < 0

{% endtest %}
