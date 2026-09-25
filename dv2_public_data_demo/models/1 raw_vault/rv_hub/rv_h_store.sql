{#-
  rv_h_store
  ==========
  Store hub. Business key: S_STORE_ID (TPC-DS natural store identifier).
  Hash key: STORE_HK (MD5 of S_STORE_ID, generated upstream in v_stg_store).

  Source: v_stg_store. The TPC-DS STORE table carries native SCD2 effectivity
  columns (s_rec_start_date / s_rec_end_date) — those flow into the
  rv_s_store_core satellite, not the hub itself. The hub stays append-only.
-#}

{%- set source_model = "v_stg_store" -%}
{%- set src_pk = "STORE_HK" -%}
{%- set src_nk = "S_STORE_ID" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
