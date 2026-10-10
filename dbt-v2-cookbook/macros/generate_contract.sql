{#
    Print the `columns:` block for a contract, read from the model as it
    was actually built. Typing 23 columns by hand is how contracts get
    types wrong; this reads them from the warehouse instead.

        dbt run-operation generate_contract \
            --args '{model_name: fct_orders}'

    Paste the output under the model in properties.yml, then set
    contract.enforced. Re-run it whenever the model's shape changes.
#}
{% macro generate_contract(model_name) %}
    {% set rel = ref(model_name) %}
    {% set cols = adapter.get_columns_in_relation(rel) %}
    {{ log("      columns:", info=True) }}
    {% for c in cols %}
        {{ log("        - name: " ~ c.name, info=True) }}
        {{ log("          data_type: " ~ c.dtype | lower, info=True) }}
    {% endfor %}
{% endmacro %}
