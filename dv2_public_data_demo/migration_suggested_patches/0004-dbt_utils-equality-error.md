Issue: dbt_utils generic test processing error
------------------------------------------------

Context
-------
- `dbt-autofix` reported KeyError processing `dbt_packages/dbt_utils/macros/generic_tests/equality.sql` during the dry-run. This likely stems from differences in how the autofix tool parsed package structure, or the vendored package layout.

Recommendations
---------------
1. Try updating `dbt_utils` to a newer release that supports the dbt version/Fusion you target. In `packages.yml` you currently have `dbt-labs/dbt_utils` pinned to `1.3.3` — consider bumping to a compatible release.
2. If upgrading is not possible, vendor-patch the failing macro locally. The failing macros are test macros under `dbt_utils/macros/generic_tests/` — inspect the macro for assumptions about `macros` keys and adapt to expected shapes.
3. If you want me to propose a local patch, I can open the failing macro and produce a minimal fix; tell me whether to modify vendored packages or provide a patch file for review.
