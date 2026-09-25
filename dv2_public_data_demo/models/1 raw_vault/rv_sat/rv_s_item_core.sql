{#-
  rv_s_item_core
  ==============
  Core descriptive satellite for hub_item.
  Captures item attributes: product name, brand, class, category,
  manufacturer, size, color, units, current price, wholesale cost.

  Parent: rv_h_item (ITEM_HK)
  Change detection: ITEM_HASHDIFF (computed upstream in v_stg_item)

  Note on price columns: i_current_price and i_wholesale_cost change over
  time in TPC-DS — including them in the hashdiff means price changes
  trigger new sat rows, giving us price history without a separate
  rv_s_item_price sat. For higher-frequency price changes, isolating
  price into its own sat would be the next-iteration design.

  TPC-DS ITEM has native SCD2 effectivity columns (i_rec_start_date,
  i_rec_end_date) that are NOT pulled into this sat — they describe the
  source's own SCD bookkeeping, which becomes redundant once DV2 takes
  over SCD via hashdiff. Including them would double-track effectivity.
-#}

{%- set source_model = "v_stg_item" -%}
{%- set src_pk = "ITEM_HK" -%}
{%- set src_hashdiff = "ITEM_HASHDIFF" -%}
{%- set src_payload = ["I_PRODUCT_NAME",
                       "I_BRAND",
                       "I_CLASS",
                       "I_CATEGORY",
                       "I_MANUFACT",
                       "I_SIZE",
                       "I_COLOR",
                       "I_UNITS",
                       "I_CURRENT_PRICE",
                       "I_WHOLESALE_COST"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk,
                   src_hashdiff=src_hashdiff,
                   src_payload=src_payload,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
