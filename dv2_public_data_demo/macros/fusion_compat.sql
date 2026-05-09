{#
  Small compatibility helpers to centralize Fusion/dbt-core differences.
  These live in the project (not vendored) so you can call them from vendored
  macros or your own models without editing package sources directly.
#}

{% macro resolve_rows_inserted(result) %}
  {%- if result is none -%}
    {{ return(0) }}
  {%- endif -%}

  {%- if 'response' in result.keys() -%}
    {%- if not result['response'].get('rows_affected') -%}
      {%- if target.type == "databricks" and result.get('data') | length > 0 -%}
        {{ return(result['data'][0][1] | int) }}
      {%- else -%}
        {{ return(0) }}
      {%- endif -%}
    {%- else -%}
      {{ return(result['response']['rows_affected']) }}
    {%- endif -%}
  {%- else -%}
    {{ return(result['status'].split(" ")[2] | int) }}
  {%- endif -%}
{% endmacro %}

{% macro commit_compat() %}
  {#
    Some older macros call `adapter.commit()` explicitly. Newer Fusion runtimes
    control transaction boundaries differently; replace direct commits with a
    no-op or use `adapter.commit()` when supported. This helper centralizes
    behavior so you can adjust in one place.
  #}
  {% if adapter is defined and adapter.commit is defined %}
    {%- do adapter.commit() -%}
  {% else %}
    {# no-op for environments that manage commits automatically #}
    {{ log("commit_compat: no-op (adapter.commit not available)") }}
  {% endif %}
{% endmacro %}
