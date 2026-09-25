<!--
SYNC IMPACT REPORT
==================
Version change:        (uninitialized template) → 1.0.0
Bump rationale:        Initial ratification. No prior versioned constitution existed
                       (file contained only template placeholders).

Principles defined (new):
  I.   Layered Architecture & Code Quality
  II.  Test-First Modeling (NON-NEGOTIABLE)
  III. Consumer Experience Consistency
  IV.  Performance by Architecture

Added sections:
  - Core Principles (4 principles)
  - Additional Constraints (Snowflake / AutomateDV / dbt-core stack)
  - Development Workflow & Quality Gates
  - Governance

Removed sections:       None (no prior content beyond placeholders).

Templates requiring updates:
  ✅ .specify/templates/plan-template.md       — Constitution Check stub remains
                                                  valid as a per-feature placeholder;
                                                  no edit needed.
  ✅ .specify/templates/spec-template.md       — Success-criteria framing aligns
                                                  with Principle IV; no edit needed.
  ⚠ .specify/templates/tasks-template.md      — "Tests OPTIONAL" note contradicts
                                                  Principle II for raw-vault models.
                                                  Pending narrow edit to reference
                                                  Principle II for data-vault work.
  ✅ .specify/templates/checklist-template.md  — Not principle-bound; no edit needed.

Runtime guidance:
  ✅ CLAUDE.md                                  — Already encodes layer rules, naming,
                                                  AutomateDV macro guidance, and the
                                                  three "active drift" items. No edit
                                                  required; constitution defers to it
                                                  for runtime conventions.
  ⚠ README.md                                  — Per CLAUDE.md, §Models is aspirational
                                                  (dataset pivot to SNOWFLAKE_SAMPLE_DATA).
                                                  Constitution does not fix this; tracked
                                                  separately as a drift item.

Follow-up TODOs:
  - None deferred at ratification time.
-->

# DV2 Public Data Demo Constitution

This constitution governs the dbt + AutomateDV + Snowflake reference implementation
in this repository. Its purpose is to keep the demo **readable in 5 minutes**: every
principle here MUST serve the goal that the repo itself is the deliverable, and that
patterns are favored over scale. The audience is other analysts and engineers reading
this codebase to learn Data Vault 2.0 — not end-users of an application.

## Core Principles

### I. Layered Architecture & Code Quality

The data flow MUST follow the four-layer topology, and each layer has one job:
`sources → 0 staging → 1 raw_vault → 2 business_vault → 3 information_mart`.
Numbered folder names (with the intentional space) are part of the contract and MUST
be preserved.

Layer rules — non-negotiable:

- **Raw vault is append-only.** Once a hub, link, or satellite row exists it is never
  updated. Change is captured as a new row. Backfills MUST use `LOAD_DATETIME` and
  `RECORD_SOURCE`, not in-place mutation.
- **Use AutomateDV macros** (`automate_dv.stage`, `automate_dv.hub`, `automate_dv.link`,
  `automate_dv.sat`) rather than hand-rolled SQL. Compiled output MUST match the staged
  CTE / `row_rank_1` shape already visible in `target/compiled/`. Custom SQL is allowed
  only in business vault and information mart — never in raw vault.
- **Hashdiff for change detection.** Satellites detect change with a single `HASHDIFF`
  column hashed across all descriptive attributes. Column-by-column comparison is
  forbidden in satellites.
- **Hash keys for joins.** Joins between hubs, links, and satellites MUST use the
  AutomateDV-generated MD5 hash keys, never raw business keys.
- **Link grain = "one row per combination observed."** Trip- or event-level facts
  belong in a transactional satellite, not in the link. Widening a link to fact-table
  grain is a violation.
- **Business vault isolates analytical decisions.** Derived metrics (e.g. `tip_pct`,
  channel revenue split) MUST live in the business vault. They MUST NOT be pushed back
  into raw-vault satellites.

Naming convention is part of the public contract: `v_stg_*` for staging views,
`rv_h_<entity>` for hubs, `rv_l_<entity>_<entity>` for links,
`rv_s_<parent>_<descriptor>` for satellites. Renames are breaking changes.

Conformance to these rules outranks personal style preferences (see CLAUDE.md
Rule 11). When in doubt, read existing compiled output before adding new SQL.

**Rationale:** The repo's value is that a reader can map a row in `information_mart`
back through the raw vault in five minutes. That property breaks the moment layers
blur, names drift, or someone hand-writes a hub.

### II. Test-First Modeling (NON-NEGOTIABLE)

Every model MUST ship with dbt tests that encode the *invariants*, not just the
shape, of the data. Tests are written before or alongside the model — never bolted
on after. A model with no tests is incomplete; CI MUST treat untested raw-vault
models as a build failure.

Required tests by layer:

- **Staging:** `not_null` and `unique` on hash keys; `not_null` on `RECORD_SOURCE`
  and `LOAD_DATETIME`.
- **Hubs:** `unique` on the hub hash key; `not_null` on the business key column(s).
- **Links:** `unique` on the link hash key; `not_null` on each parent hub hash key.
- **Satellites:** `unique` on the composite of `(parent_hash_key, LOAD_DATETIME)`;
  `not_null` on `HASHDIFF`.
- **Business vault / information mart:** at least one test that fails when the
  business rule changes — generic `not_null` / `unique` is not sufficient on its own.

Test rules:

- Tests verify intent, not just behavior. A test that cannot fail when the business
  logic changes is wrong and MUST be replaced (see CLAUDE.md Rule 9).
- `dbt build` (not just `dbt run`) MUST pass locally and in CI before merge. Skipped
  tests are surfaced loudly and require an inline justification with an owner and an
  expiry date.
- Source freshness checks MUST exist on every declared source.

**Rationale:** A Data Vault's correctness is structural — hub uniqueness, hashdiff
sensitivity, link grain. None of these are visible by eyeballing SQL. Tests are the
only durable proof that the invariants in Principle I still hold after each change.

### III. Consumer Experience Consistency

This repo has two consumers: humans reading it to learn Data Vault, and BI tools
querying `INFORMATION_MART`. Both experiences MUST stay consistent.

For human readers:

- Folder ordering (`0 staging`, `1 raw_vault`, …) follows DAG order. New folders MUST
  fit the sequence.
- `dbt docs generate` MUST produce a complete graph: every model has a description,
  every column on a public-facing mart has a description, every source is documented.
- Examples in `README.md` MUST match what `dbt build` actually produces. When the
  README and the compiled output diverge, the README is wrong and MUST be updated in
  the same PR as the model change.

For BI / SQL consumers:

- `INFORMATION_MART` is the only sanctioned read surface. Dashboards and ad-hoc
  queries MUST NOT join raw-vault tables directly.
- Schema names (`RAW_VAULT`, `BUSINESS_VAULT`, `INFORMATION_MART`) are stable. The
  `macros/generate_schema_name.sql` override that produces them is load-bearing and
  MUST NOT be reverted without a redesign of the layer layout.
- Column names exposed in marts use the same casing and naming convention across
  models. Renames in marts are breaking changes and require a deprecation note in the
  model's `description:`.

**Rationale:** The repo's selling point is "readable in 5 minutes." Every
inconsistency — a misnumbered folder, an undocumented mart column, a README that
contradicts the compiled SQL — costs the reader trust and time. Consistency is the UX.

### IV. Performance by Architecture

Performance MUST come from the *shape* of the model, not from query-time tuning.
Tuning is a last resort and requires a documented reason.

Required patterns:

- **Hash-key joins, not natural-key joins.** Fixed-width MD5 keys cluster well on
  Snowflake and keep joins O(probe).
- **Projection over computation.** Marts read pre-built current-state projections.
  Public-facing models MUST NOT aggregate raw vault on every query when an
  incremental projection would serve.
- **Append-only writes eliminate contention.** Satellites are insert-only; updates
  to existing rows are a smell that points to a missing hashdiff or a mis-graned
  link (see Principle I).
- **Incrementality where it matters.** Hubs, links, and satellites SHOULD be
  materialized as `incremental` once the source row count makes a full refresh
  noticeably slower than an incremental run. Staging stays as views.

Forbidden without justification:

- `SELECT *` in raw-vault or business-vault models.
- Cross-joins or Cartesian products in any production model.
- Per-row UDFs or scalar subqueries inside hot-path satellites.

Performance regressions MUST be measured (`dbt build` wall-clock and / or Snowflake
query profile) before they're called regressions. "It feels slow" is not a finding
(see CLAUDE.md Rule 9 and the Wisdom Seeds: *measure before you optimize*).

**Rationale:** Data Vault gets a reputation for slow joins precisely when teams
violate the architecture — hand-rolled keys, full scans for current state, link
tables widened to event grain. Honoring the shape gives you performance for free.

## Additional Constraints — Stack & Compliance

- **Runtime:** Snowflake. Porting raw-vault models to BigQuery or Databricks is
  supported by AutomateDV but is out of scope for this demo. PRs that add another
  warehouse target MUST justify the complexity (see Complexity Tracking in the plan
  template).
- **Working directory:** All `dbt` commands run from `dv2_public_data_demo/`, not
  the repo root. Scripts, CI workflows, and docs MUST reflect this path.
- **Pinned packages:** `Datavault-UK/automate_dv` `0.11.5`,
  `dbt-labs/dbt_utils` `1.3.3`, `Snowflake-Labs/dbt_semantic_view` `1.0.3`. Bumping
  AutomateDV is the highest-risk dependency change — macro signatures shift between
  minor versions. Any version bump requires a regenerated `target/compiled/` diff in
  the PR description.
- **Profiles:** `dv2_public_data_demo/profiles.yml` is checked in with `'not needed'`
  placeholders. Real credentials MUST NOT be committed; local runs copy the file to
  `~/.dbt/profiles.yml`. Secrets in CI use OIDC and the GitHub `prod` environment.
- **`RECORD_SOURCE` is required** on every staging model, even in the
  single-source case. Removing it is a breaking change to the multi-source narrative.

## Development Workflow & Quality Gates

- **Read before you write.** Before adding a model, read its immediate upstream
  staging view, the relevant compiled output under `target/compiled/`, and any
  existing tests. Before modifying a macro, grep for all callers.
- **Surgical changes.** Touch only what the task requires. Drive-by refactors of
  adjacent models are rejected at review (see CLAUDE.md Rule 3).
- **Active drift items** (from CLAUDE.md) are NOT swept opportunistically:
  README dataset narrative, `dbt_project.yml` name, CI `--source ./tasty_bytes`
  path. Each requires an explicit ticket and a separate PR.
- **CI gates:** Both `.github/workflows/incoming_pr.yml` and `pr_merged.yml` MUST
  pass. CI uses Snowflake CLI's native dbt-project objects, not `dbt-core` directly,
  so a green local `dbt build` is necessary but not sufficient.
- **Commits and PRs:** Conventional Commit prefixes (`feat:`, `fix:`, `refactor:`,
  `docs:`, `test:`, `chore:`, `perf:`, `ci:`). PR descriptions MUST list affected
  layers and call out any new tests or removed assertions.

## Governance

This constitution supersedes ad-hoc conventions inside this repo. When it conflicts
with `CLAUDE.md`, the **more specific** rule wins; if both are equally specific,
this constitution wins and `CLAUDE.md` MUST be reconciled in the same PR.

**Amendment procedure:**

1. Propose the amendment in a PR that edits this file.
2. Include a Sync Impact Report (the HTML comment block at the top) describing
   version change, principles touched, and templates affected.
3. Update every dependent template (`plan-template.md`, `spec-template.md`,
   `tasks-template.md`, `checklist-template.md`) in the same PR — no straggler
   commits.
4. Bump `CONSTITUTION_VERSION` per semantic versioning:
   - **MAJOR:** A principle is removed, redefined to be backward-incompatible, or
     governance rules change in a way that invalidates prior PRs.
   - **MINOR:** A new principle or section is added, or existing guidance is
     materially expanded.
   - **PATCH:** Clarification, wording, or non-semantic refinement.

**Compliance review:**

- Every PR that adds or modifies a model MUST self-attest in the description that
  Principles I–IV were considered. The PR template SHOULD prompt for this.
- Reviewers cite the principle number on any blocking comment (e.g. "Principle I:
  raw-vault is append-only").
- Complexity that violates a principle MUST be entered in the Complexity Tracking
  table of the plan template with a rejected simpler alternative — silent
  exceptions are not granted.

Runtime development guidance — naming, layer details, the three active drift items,
working-directory rules — lives in `CLAUDE.md`. This constitution defines the
*rules*; `CLAUDE.md` defines the *practices* that implement them.

**Version**: 1.0.0 | **Ratified**: 2026-05-18 | **Last Amended**: 2026-05-18
