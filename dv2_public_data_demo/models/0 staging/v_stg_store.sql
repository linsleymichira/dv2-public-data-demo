{%- set yaml_metadata -%}

source_model:

    SNOWFLAKE_SAMPLE_DATA: STORE

hashed_columns:

  STORE_HK: "S_STORE_ID"

  MARKET_HK: "S_MARKET_ID"

  DIVISION_HK: "S_DIVISION_ID"

derived_columns:

  RECORD_SOURCE: "!1"

  EFFCTIVE_FROM: "S_REC_START_DATE"

  EFFCTIVE_TO: "S_REC_END_DATE"

null_columns:

  required: 
    - S_STORE_ID
 
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
                     