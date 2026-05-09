Migration notes — dv2_public_data_demo -> dbt Fusion
==================================================

Summary
-------
- Automated `dbt-autofix deprecations` run and fixes applied to `dbt_project.yml` files (committed on branch `feat/migrate-to-fusion-autofix`).
- The project still contains macros/materializations that require manual edits for Fusion compatibility (mostly around direct adapter calls, `load_result` handling, and temp-relation handling).

What I changed (already)
------------------------
- Committed automated deprecation fixes to:
  - `dbt_project.yml`
  - `dbt_packages/dbt_semantic_view/dbt_project.yml`
  - `dbt_packages/dbt_utils/dbt_project.yml`
  - `dbt_packages/automate_dv/dbt_project.yml`

Guiding principle for manual changes
-----------------------------------
- Do NOT edit vendored packages if you want to preserve upgradability. Instead either:
  - Patch the package locally and vendor the changes (makes future upgrades manual), or
  - Submit PRs upstream to the package(s), or
  - Add small adapter-compat shims in your project (recommended for quick migration).

Recommended minimal approach (what I suggest)
--------------------------------------------
1. Add a project-level compatibility macro to handle variations in `load_result`, `adapter.commit()`, and temporary relation helpers. I created a suggested macro at `macros/fusion_compat.sql` (below).
2. Replace the fragile, repeated `load_result` parsing and explicit `adapter.commit()` calls inside vendored materializations with calls to the compatibility helpers. Suggested diffs are in `migration_suggested_patches/`.
3. Run `dbt parse` and `dbt compile` to validate templates, then run unit/integration tests.

Files that need manual review / suggested edits
----------------------------------------------
- dbt_packages/automate_dv/macros/materialisations/vault_insert_by_period_materialization.sql
- dbt_packages/automate_dv/macros/materialisations/incremental_pit_materialization.sql
- dbt_packages/automate_dv/macros/materialisations/incremental_bridge_materialization.sql
- dbt_packages/automate_dv/macros/materialisations/vault_insert_by_rank_materialization.sql
- dbt_packages/dbt_semantic_view/macros/materializations/semantic_view.sql
- dbt_packages/dbt_utils/macros/generic_tests/equality.sql (autofix raised a KeyError; consider upgrading `dbt_utils` or patching the failing macro)

Suggested next steps
---------------------
1. Review the compatibility macro `macros/fusion_compat.sql` and the suggested patch files in `migration_suggested_patches/`.
2. If you prefer not to vendor-patch packages, we can add lightweight wrapper macros in your project and call them from the models that reference those macros.
3. After applying patches (either vendored or local wrappers), run:

```bash
dbt parse
dbt compile
dbt test --models tag:fast  # optional
```

Suggested patches are stored in `migration_suggested_patches/` as `.diff` files for you to review and apply.

If you'd like, I can open PR with the suggested changes or apply them to this branch after your approval.

End of notes.
