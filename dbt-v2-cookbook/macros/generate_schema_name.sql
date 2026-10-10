{#
    dbt's default prepends the target schema, so `+schema: bronze` on target
    `main` produces `main_bronze`. That is a safety feature: two developers
    on one warehouse get separate schemas and cannot overwrite each other.

    Overriding it to use the custom name verbatim gives you `bronze`,
    `silver`, `gold` -- which reads better and is what most medallion
    projects want in production. The cost is that every developer now writes
    to the SAME schema. Only do this when each environment has its own
    database or catalog.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
