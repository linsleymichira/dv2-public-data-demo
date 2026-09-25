{#-
  rv_h_sales
  ==========
  Sales-event hub. Business key: composite (SS_TICKET_NUMBER + SS_SOLD_DATE_SK
  + SS_ITEM_SK) — the line-item-grain identifier of a single sale event.
  Hash key: SALES_HK (MD5 composite, generated upstream in v_stg_store_sales).

  Source: v_stg_store_sales.

  Why this is a hub and not just a link: TPC-DS sale lines have a stable
  business identity — they're referenced by STORE_RETURNS via
  (sr_ticket_number, sr_item_sk) and by downstream customer-service systems
  via ticket lookups. Modeling sale events as a hub (rather than burying
  their identity in a link's hash) keeps that cross-system reference clean.
  This is the "transaction hub" DV2 pattern — less common than entity-only
  hubs but defensible when events have durable BKs.

  The natural-key concept here is the COMBINATION of the three columns;
  the hub stores all three as `src_nk` so audit can reconstruct the BK.
-#}

{%- set source_model = "v_stg_store_sales" -%}
{%- set src_pk = "SALES_HK" -%}
{%- set src_nk = ["SS_TICKET_NUMBER", "SS_SOLD_DATE_SK", "SS_ITEM_SK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
