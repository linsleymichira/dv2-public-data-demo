Suggested change for: dbt_packages/automate_dv/macros/materialisations/incremental_pit_materialization.sql

Issue
-----
- Same pattern as vault_insert: `load_result`, `adapter.commit()` and temporary relation handling appear multiple times.

Suggested edits
---------------
- Replace `load_result(...)` parsing blocks with `fusion_compat.resolve_rows_inserted(result)` as shown in `0001`.
- Replace `adapter.commit()` with `fusion_compat.commit_compat()`.
- If code uses `tmp_relation.include(schema=True)` prefer `tmp_relation` usage consistent with the macro's target-relation APIs or wrap in a compatibility call.

Notes
-----
- This file contains `run_query(create_table_as(True, tmp_relation, sql))` patterns. Ensure `create_table_as` and `run_query` calls remain correct for the adapter; only change how results are parsed and commits are invoked.
