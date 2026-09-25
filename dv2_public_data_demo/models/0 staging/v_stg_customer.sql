{%- set yaml_metadata -%}

source_model:

    SNOWFLAKE_SAMPLE_DATA: CUSTOMER

hashed_columns:

  CUSTOMER_HK: "C_CUSTOMER_ID"

  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - "C_FIRST_NAME"
      - "C_LAST_NAME"
      - "C_SALUTATION"
      - "C_EMAIL_ADDRESS"
      - "C_BIRTH_YEAR"
      - "C_PREFERRED_CUST_FLAG"

derived_columns:

  RECORD_SOURCE: "!1"

null_columns:

  required: 
    - C_CUSTOMER_SK
 

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
