# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A minimal Data Vault 2.0 reference implementation: **dbt-core + AutomateDV on Snowflake**, intended to be readable in 5 minutes. The deliverable is the repo itself — patterns over scale.

## Working directory

All dbt commands run from `dv2_public_data_demo/` (not the repo root). `dbt_project.yml`, `packages.yml`, `profiles.yml`, `macros/`, and (when present) `models/` all live one level down.

```bash
cd dv2_public_data_demo
dbt deps           # install automate_dv, dbt_utils, dbt_semantic_view
dbt build          # compile, run, test in DAG order
dbt run --select <model>           # build a single model
dbt test --select <model>          # test a single model
dbt build --select +<model>+       # model and its full upstream + downstream
dbt docs generate && dbt docs serve
```

## Active drift you will hit (read before editing)

The repo is mid-pivot and has three concrete inconsistencies that are not bugs to fix opportunistically — confirm intent first:

1. **Source dataset.** README still describes the Cybersyn NYC TLC marketplace dataset. Actual source per compiled artifacts and project notes is `SNOWFLAKE_SAMPLE_DATA` (TPC-DS schemas). Narrative pivoted to multi-channel retail integration (store/web/catalog sales feeding shared hubs). Treat README §Models as aspirational, not authoritative.
2. **Project name.** `dbt_project.yml` declares `name: tasty_bytes` and `profile: tasty_bytes`; `profiles.yml` matches. But `.github/workflows/*.yml` references `--source ./tasty_bytes` (a path that does not exist — actual source is `./dv2_public_data_demo`), and `target/compiled/` shows the project name compiled as `dv2_public_data_demo`. The CI workflows are broken on path; the project name itself is a placeholder leftover from a Snowflake quickstart template.
3. **`models/` is empty in the working tree.** Only `target/compiled/` retains prior model shapes (a mix of older IRS 990 staging and current TPC-DS staging + raw-vault hubs/links). Use compiled SQL as archaeology, not spec — names and grains may have changed.

## Architecture (intended layering)

```
sources (Snowflake Marketplace / SNOWFLAKE_SAMPLE_DATA, zero-copy)
   └─ 0 staging/        v_stg_*  (views; AutomateDV-generated hash keys, RECORD_SOURCE, LOAD_DATETIME)
        └─ 1 raw_vault/
             ├─ rv_hub/  rv_h_*   (business keys, immutable, append-only)
             ├─ rv_lnk/  rv_l_*   (hub × hub relationships, one row per combination observed)
             └─ rv_sat/  rv_s_*   (SCD2 descriptive attrs, change detected via HASHDIFF)
        └─ 2 business_vault/      (derived metrics — analytical decisions isolated here)
        └─ 3 information_mart/    (flat denormalized views for BI tools)
```

Layer rules that matter:

- **Raw vault is append-only.** Once a hub/link/sat row exists, it is not updated. Change is captured as a new row.
- **Hashdiff, not column comparison.** Satellites detect change with a single `HASHDIFF` column hashed across all descriptive attrs — O(1) per row regardless of satellite width.
- **Hash keys, not natural keys, for joins.** Fixed-width MD5 (AutomateDV default) keeps joins fast and clusters well on Snowflake.
- **Link grain = "one row per combination observed."** Trip/event-level facts belong in a transactional satellite, not in the link. Don't widen links to fact-table grain.
- **Business vault separates analytical decisions** (e.g., `tip_pct`, channel revenue split) from the audit-grade raw vault. Don't push derived metrics back into satellites.

When reconstructing or adding models, use AutomateDV macros (`automate_dv.stage`, `automate_dv.hub`, `automate_dv.link`, `automate_dv.sat`) rather than hand-written SQL — the compiled output should match the staged-CTE / `row_rank_1` shapes already visible in `target/compiled/`.

## Schema routing

`macros/generate_schema_name.sql` overrides dbt's default schema-naming so a model's `+schema:` config is used **verbatim**, without the `target.schema_` prefix. This is what lets `RAW_VAULT`, `BUSINESS_VAULT`, `INFORMATION_MART` coexist as separate Snowflake schemas in the same target. Don't restore the default behavior without redesigning the layer layout.

## CI

Two GitHub Actions workflows in `.github/workflows/`:

- `incoming_pr.yml` — on PR open/sync, deploys a tester dbt-project object via `snow dbt deploy` and runs `snow dbt execute … build --target dev`.
- `pr_merged.yml` — on push to `main`, deploys the prod dbt-project object with `--default-target prod`.

Both use the **Snowflake CLI's native dbt-project objects** (`SNOWFLAKE_CLI_FEATURES_ENABLE_DBT=true`) with OIDC auth — not `dbt-core` directly. CI execution surface is therefore not identical to local `dbt build`. Both workflows currently point at `--source ./tasty_bytes`, which does not match the on-disk path (`./dv2_public_data_demo`); fix the source flag before relying on CI.

Required GitHub secrets/vars: `SNOWFLAKE_ACCOUNT` (secret), `SNOWFLAKE_DATABASE` (var), `SNOWFLAKE_SCHEMA` (var). Environment `prod` must match the OIDC subject.

## Profiles

`dv2_public_data_demo/profiles.yml` is checked in with `'not needed'` placeholders for `account` and `user`. For local runs, copy to `~/.dbt/profiles.yml` and fill in real values — don't commit real credentials back to the tracked file.

## Conventions

- Staging models: `v_stg_<source_table>` (views).
- Hubs: `rv_h_<entity>`. Links: `rv_l_<entity>_<entity>`. Satellites: `rv_s_<parent_hub_or_link>_<descriptor>`.
- Folders are numbered (`0 staging`, `1 raw_vault`, …) to enforce DAG-order readability. The space in folder names is intentional; preserve it.
- `RECORD_SOURCE` is required on every staging model. With a single source it's cosmetic; the multi-source narrative is where it earns its keep, so don't drop it.

## Packages

Pinned in `packages.yml`:

- `Datavault-UK/automate_dv` 0.11.5 — the Data Vault macro library (Snowflake-first; porting to BigQuery/Databricks is supported but less tested).
- `dbt-labs/dbt_utils` 1.3.3
- `Snowflake-Labs/dbt_semantic_view` 1.0.3

Bumping AutomateDV is the highest-risk dep change — macro signatures shift between minor versions.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
