{#-
  rv_nhl_return_transaction
  =========================
  Non-historized link: customer × item × store × return-event.
  One row per return line (line-item grain). Append-only.

  PK:    LINK_RETURN_HK (composite hash of all 6 natural BKs upstream)
  FKs:   CUSTOMER_HK, ITEM_HK, STORE_HK, RETURNS_HK
  Payload: return measures (quantity, return amount, refund cash, net loss).
           Mirrors sale payload structure for ease of joining
           sales-to-returns at the IM layer.

  Source: v_stg_store_returns.

  Note on returns→sales linkage: in TPC-DS, a return's (sr_ticket_number,
  sr_item_sk) join keys equal the original sale's (ss_ticket_number,
  ss_item_sk). That join happens in the information mart, not here — the
  raw vault stores returns as their own first-class events.
-#}

{%- set source_model = "v_stg_store_returns" -%}
{%- set src_pk = "LINK_RETURN_HK" -%}
{%- set src_fk = ["CUSTOMER_HK", "ITEM_HK", "STORE_HK", "RETURNS_HK"] -%}
{%- set src_payload = ["SR_RETURN_QUANTITY",
                       "SR_RETURN_AMT",
                       "SR_RETURN_TAX",
                       "SR_RETURN_AMT_INC_TAX",
                       "SR_FEE",
                       "SR_RETURN_SHIP_COST",
                       "SR_REFUNDED_CASH",
                       "SR_REVERSED_CHARGE",
                       "SR_STORE_CREDIT",
                       "SR_NET_LOSS",
                       "SR_REASON_SK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.t_link(src_pk=src_pk,
                      src_fk=src_fk,
                      src_payload=src_payload,
                      src_ldts=src_ldts,
                      src_source=src_source,
                      source_model=source_model) }}
