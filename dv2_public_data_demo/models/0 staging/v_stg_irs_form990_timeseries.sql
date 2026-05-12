{{ config(materialized="view") }}

{%- set yaml_metadata -%}

source_model:
    SNOWFLAKE_PUBLIC_DATA_FREE: "IRS_FORM990_TIMESERIES"

derived_columns:

hashed_columns:

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{
    automate_dv.stage(
        include_source_columns=true,
        source_model=metadata_dict["source_model"],
        derived_columns=metadata_dict["derived_columns"],
        null_columns=none,
        hashed_columns=metadata_dict["hashed_columns"],
        ranked_columns=none,
    )
}}
