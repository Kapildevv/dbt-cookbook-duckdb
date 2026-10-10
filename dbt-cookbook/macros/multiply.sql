{# A trivial macro, to show the mechanics: Jinja returns SQL text. #}
{% macro multiply(x, y) %}
    {{ x }} * {{ y }}
{% endmacro %}
