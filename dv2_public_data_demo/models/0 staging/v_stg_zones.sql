{{ config(materialized="view") }}

{%- set yaml_metadata -%}

source_model: 
  nyc_taxi_zones: "TAXI_ZONE_GEOM"

derived_columns:

  SOURCE: "!NYC_TAXI_ZONES"

  LOAD_DATETIME: "_META_LOADED_AT"

  BOROUGH: "BOROUGH"

  ZONE_GEOM: "GEOM"

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
