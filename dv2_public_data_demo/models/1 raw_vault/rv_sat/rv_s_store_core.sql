{#-
  rv_s_store_core
  ===============
  Core descriptive satellite for hub_store.
  Captures store attributes: name, company, city/state/zip/country,
  manager, market-manager.

  Parent: rv_h_store (STORE_HK)
  Change detection: STORE_HASHDIFF (computed upstream in v_stg_store)

  TPC-DS STORE carries native SCD2 columns (s_rec_start_date / s_rec_end_date)
  surfaced as EFFCTIVE_FROM / EFFCTIVE_TO (sic — typo preserved upstream)
  in v_stg_store. v1 does not pass these through as effectivity to the
  AutomateDV sat — DV2 hashdiff captures the same change events from the
  payload columns. Including them would double-track effectivity.
-#}

{%- set source_model = "v_stg_store" -%}
{%- set src_pk = "STORE_HK" -%}
{%- set src_hashdiff = "STORE_HASHDIFF" -%}
{%- set src_payload = ["S_STORE_NAME",
                       "S_COMPANY_NAME",
                       "S_CITY",
                       "S_STATE",
                       "S_ZIP",
                       "S_COUNTRY",
                       "S_MANAGER",
                       "S_MARKET_MANAGER"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk,
                   src_hashdiff=src_hashdiff,
                   src_payload=src_payload,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
