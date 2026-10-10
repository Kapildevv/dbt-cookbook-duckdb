{#
    Pull a field out of a JSON column as text.

    The point of wrapping this: the function name differs by warehouse.
    DuckDB and Postgres have json_extract_string; Databricks and Spark have
    get_json_object; BigQuery has JSON_VALUE; Snowflake uses a colon path.
    One macro means one place to change when you port.
#}
{% macro json_field(column, path) -%}
    json_extract_string({{ column }}, '$.{{ path }}')
{%- endmacro %}
