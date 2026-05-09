{{ config(materialized="view") }}

{%- set yaml_metadata -%}

source_model: 
  nyc_taxi_zones: "taxi_zones"

derived_columns:

  SOURCE: "!NYC_TAXI_ZONES"

  LOAD_DATETIME: "CRM_DATA_INGESTION_TIME"

  EFFECTIVE_FROM: "BOOKING_DATE"

  START_DATE: "BOOKING_DATE"

  END_DATE: "TO_DATE('9999-12-31')"

  PICKUP_LOCATION_ID: "LOCATION_ID"

  ZONE_NAME: "ZONE"

  BOROUGH: "BOROUGH"

  ZONE_GEOM: "GEOM"

hashed_columns:

  CUSTOMER_HK: "CUSTOMER_ID"

  NATION_HK: "NATION_ID"

  CUSTOMER_NATION_HK:
    - "CUSTOMER_ID"
    - "NATION_ID"

  CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - "CUSTOMER_NAME"
      - "CUSTOMER_ID"
      - "CUSTOMER_PHONE"
      - "CUSTOMER_DOB"

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
