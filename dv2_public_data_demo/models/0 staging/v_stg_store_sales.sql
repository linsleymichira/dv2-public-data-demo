{%- set yaml_metadata -%}

source_model: pre_stg_store_sales

hashed_columns:

  CUSTOMER_HK: "C_CUSTOMER_ID"

  ITEM_HK: "I_ITEM_ID"

  STORE_HK: "S_STORE_ID"

  ## TODO(human): define SALES_HK below.
  ##
  ## SALES_HK is the composite event hash key — the unique identifier of a
  ## single sale-line event. It must be deterministic and collision-resistant
  ## across the line-item grain (one row per ticket × item × business day).
  ##
  ## AutomateDV supports two YAML syntaxes for composite hashes:
  ##
  ##   (1) Comma-separated string (matches the AutomateDV docs example):
  ##       SALES_HK: "SS_TICKET_NUMBER, SS_SOLD_DATE_SK, SS_ITEM_SK"
  ##
  ##   (2) YAML list:
  ##       SALES_HK:
  ##         - "SS_TICKET_NUMBER"
  ##         - "SS_SOLD_DATE_SK"
  ##         - "SS_ITEM_SK"
  ##
  ## Constraint: the columns you choose must, together, uniquely identify
  ## one sale line. ss_ticket_number alone is NOT unique across business
  ## days — TPC-DS recycles ticket numbers. The combination above is the
  ## minimal sufficient set, but you could also include ss_store_sk if you
  ## want the hash to encode the originating store explicitly (defensible
  ## either way — stores don't change post-sale, so it's redundant for
  ## uniqueness but informative for debugging).
  ##
  ## AutomateDV handles null-coalescing and uppercasing internally — you
  ## don't need to wrap columns in COALESCE or UPPER.
  ##
  ## Pick a syntax (1 or 2), pick your column set, and write the SALES_HK
  ## entry between the markers below.

  SALES_HK:
    - "SS_TICKET_NUMBER"
    - "SS_SOLD_DATE_SK"
    - "SS_ITEM_SK"

  LINK_SALE_HK:
    - "C_CUSTOMER_ID"
    - "I_ITEM_ID"
    - "S_STORE_ID"
    - "SS_TICKET_NUMBER"
    - "SS_SOLD_DATE_SK"
    - "SS_ITEM_SK"

derived_columns:

  RECORD_SOURCE: "!STORE_SALES"

null_columns:

  required:
    - C_CUSTOMER_ID
    - I_ITEM_ID
    - S_STORE_ID
    - SS_TICKET_NUMBER
    - SS_SOLD_DATE_SK
    - SS_ITEM_SK

ranked_columns:


{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict["source_model"] %}
{% set derived_columns = metadata_dict["derived_columns"] %}
{% set null_columns = metadata_dict["null_columns"] %}
{% set hashed_columns = metadata_dict["hashed_columns"] %}
{% set ranked_columns = metadata_dict["ranked_columns"] %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=source_model,
                     derived_columns=derived_columns,
                     null_columns=null_columns,
                     hashed_columns=hashed_columns,
                     ranked_columns=ranked_columns) }}
