{#-
  rv_h_customer
  =============
  Customer hub. Business key: C_CUSTOMER_ID (TPC-DS natural customer identifier).
  Hash key: CUSTOMER_HK (MD5 of C_CUSTOMER_ID, generated upstream in v_stg_customer).

  Source: v_stg_customer (single-source for v1). Multi-source feeding from
  v_stg_store_sales is a v1.1 stretch — populate the hub at first sight of
  any customer in any fact stream.
-#}

{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "CUSTOMER_HK" -%}
{%- set src_nk = "C_CUSTOMER_ID" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
