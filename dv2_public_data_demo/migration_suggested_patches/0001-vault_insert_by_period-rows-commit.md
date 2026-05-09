Suggested change for: dbt_packages/automate_dv/macros/materialisations/vault_insert_by_period_materialization.sql

Issue
-----
- The macro repeatedly parses `load_result(...)` dictionaries to compute `rows_inserted` and calls `adapter.commit()` directly. These patterns vary across dbt/Fusion runtime versions and cause maintenance burden.

Suggested replacement (project-level shim approach)
-----------------------------------------------
1) Add the project helper `macros/fusion_compat.sql` (already added) which exposes:
   - `fusion_compat.resolve_rows_inserted(result)` -> returns an integer robustly across result shapes.
   - `fusion_compat.commit_compat()` -> centralizes commit behavior.

2) Replace the old parsing blocks with calls to those helpers. Example transformation:

OLD (excerpt):
```jinja
{% set result = load_result(insert_query_name) %}
{% if 'response' in result.keys() %}
  {%- if not result['response']['rows_affected'] %}
    {% if target.type == "databricks" and result['data'] | length > 0 %}
      {% set rows_inserted = result['data'][0][1] | int %}
    {% else %}
      {% set rows_inserted = 0 %}
    {% endif %}
  {%- else %}
    {% set rows_inserted = result['response']['rows_affected'] %}
  {%- endif %}
{% else %}
  {% set rows_inserted = result['status'].split(" ")[2] | int %}
{% endif %}
```

NEW (excerpt):
```jinja
{% set result = load_result(insert_query_name) %}
{% set rows_inserted = fusion_compat.resolve_rows_inserted(result) %}
```

Also replace direct commits like:
```jinja
{% do adapter.commit() %}
```
with:
```jinja
{% do fusion_compat.commit_compat() %}
```

Rationale
---------
- Centralizes and documents compatibility logic.
- Keeps vendored packages untouched (you can apply the replacements locally when ready).
