{#-
  rv_h_returns
  ============
  Returns-event hub. Business key: composite (SR_TICKET_NUMBER + SR_RETURNED_DATE_SK
  + SR_ITEM_SK) — line-item-grain identifier of a single return event.
  Hash key: RETURNS_HK (MD5 composite, generated upstream in v_stg_store_returns).

  Source: v_stg_store_returns.

  Returns are modeled as their own hub (parallel to rv_h_sales) for the
  same reason: a return has a stable business identity referenced by
  customer service and accounting downstream. The (sr_ticket_number,
  sr_item_sk) pair joins each return back to the originating sale, but
  that join is captured at the LINK layer, not by collapsing returns
  into the sales hub.
-#}

{%- set source_model = "v_stg_store_returns" -%}
{%- set src_pk = "RETURNS_HK" -%}
{%- set src_nk = ["SR_TICKET_NUMBER", "SR_RETURNED_DATE_SK", "SR_ITEM_SK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
