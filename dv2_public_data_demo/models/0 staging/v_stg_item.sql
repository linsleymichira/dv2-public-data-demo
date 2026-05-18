{%- set yaml_metadata -%}

source_model:

    SNOWFLAKE_SAMPLE_DATA: ITEM

hashed_columns:

  ITEM_HK: "I_ITEM_ID"

  ITEM_HASHDIFF:
    is_hashdiff: true
    columns:
      - "I_PRODUCT_NAME"
      - "I_BRAND"
      - "I_CLASS"
      - "I_CATEGORY"
      - "I_MANUFACT"
      - "I_SIZE"
      - "I_COLOR"
      - "I_UNITS"
      - "I_CURRENT_PRICE"
      - "I_WHOLESALE_COST"

derived_columns:

  RECORD_SOURCE: "!ITEM"

null_columns:

  required:
    - I_ITEM_ID

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
