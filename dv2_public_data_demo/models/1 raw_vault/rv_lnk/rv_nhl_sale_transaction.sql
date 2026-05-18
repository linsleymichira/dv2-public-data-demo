{#-
  rv_nhl_sale_transaction
  =======================
  Non-historized link: customer × item × store × sale-event.
  One row per sale line (line-item grain). Append-only — sale events don't
  change post-occurrence, which is why this is a t_link not a regular link
  with a sat tracking effectivity.

  PK:    LINK_SALE_HK (composite hash of all 6 natural BKs upstream)
  FKs:   CUSTOMER_HK, ITEM_HK, STORE_HK, SALES_HK
  Payload: sale measures (quantity, sales price, ext sales price, net paid,
           net profit, promo). Non-historized links carry payload because
           the values are immutable for a given event — no sat needed.

  Source: v_stg_store_sales (line-item grain, with surrogate→natural BK
  translation already resolved upstream in pre_stg_store_sales).
-#}

{%- set source_model = "v_stg_store_sales" -%}
{%- set src_pk = "LINK_SALE_HK" -%}
{%- set src_fk = ["CUSTOMER_HK", "ITEM_HK", "STORE_HK", "SALES_HK"] -%}
{%- set src_payload = ["SS_QUANTITY",
                       "SS_WHOLESALE_COST",
                       "SS_LIST_PRICE",
                       "SS_SALES_PRICE",
                       "SS_EXT_SALES_PRICE",
                       "SS_EXT_DISCOUNT_AMT",
                       "SS_EXT_TAX",
                       "SS_NET_PAID",
                       "SS_NET_PAID_INC_TAX",
                       "SS_NET_PROFIT",
                       "SS_PROMO_SK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.t_link(src_pk=src_pk,
                      src_fk=src_fk,
                      src_payload=src_payload,
                      src_ldts=src_ldts,
                      src_source=src_source,
                      source_model=source_model) }}
