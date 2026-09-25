{%- set yaml_metadata -%}

source_model: pre_stg_store_returns

hashed_columns:

  CUSTOMER_HK: "C_CUSTOMER_ID"

  ITEM_HK: "I_ITEM_ID"

  STORE_HK: "S_STORE_ID"

  RETURNS_HK:
    - "SR_TICKET_NUMBER"
    - "SR_RETURNED_DATE_SK"
    - "SR_ITEM_SK"

  LINK_RETURN_HK:
    - "C_CUSTOMER_ID"
    - "I_ITEM_ID"
    - "S_STORE_ID"
    - "SR_TICKET_NUMBER"
    - "SR_RETURNED_DATE_SK"
    - "SR_ITEM_SK"

derived_columns:

  RECORD_SOURCE: "!STORE_RETURNS"

null_columns:

  required:
    - C_CUSTOMER_ID
    - I_ITEM_ID
    - S_STORE_ID
    - SR_TICKET_NUMBER
    - SR_RETURNED_DATE_SK
    - SR_ITEM_SK

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
