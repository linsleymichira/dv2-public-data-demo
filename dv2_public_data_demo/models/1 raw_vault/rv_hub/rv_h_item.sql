{#-
  rv_h_item
  =========
  Item hub. Business key: I_ITEM_ID (TPC-DS natural item identifier).
  Hash key: ITEM_HK (MD5 of I_ITEM_ID, generated upstream in v_stg_item).

  Source: v_stg_item (single-source). TPC-DS ITEM is shared across all three
  fact channels (store, web, catalog), so this is the natural multi-source-hub
  candidate in v1.1.
-#}

{%- set source_model = "v_stg_item" -%}
{%- set src_pk = "ITEM_HK" -%}
{%- set src_nk = "I_ITEM_ID" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
