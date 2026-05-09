Suggested change for: dbt_packages/dbt_semantic_view/macros/materializations/semantic_view.sql

Issue
-----
- The semantic_view materialization relies on adapter-specific temp-relation behavior and `create_table_as` with language flags. Fusion may use the `api.Relation`/`Relation` helpers and different tmp relation semantics.

Suggested edits
---------------
- Where the materialization constructs a temp relation via `make_temp_relation(this).incorporate(type=tmp_relation_type)`, confirm the tmp relation type choices map to Fusion's `Relation` API. If necessary, add a compatibility wrapper in your project to normalize `tmp_relation` creation.
- Replace direct `adapter.drop_relation(existing_relation)` / `adapter.commit()` calls with calls to project-level wrappers if you plan to run on Fusion.

Minimal change recommendation
--------------------------
- Prefer adding shim macros in your project and call them from the materialization. Example shim names: `fusion_compat.make_temp_relation_compat(relation, tmp_type)` and `fusion_compat.drop_relation_compat(rel)`.
