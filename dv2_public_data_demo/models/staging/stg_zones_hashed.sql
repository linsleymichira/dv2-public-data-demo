{{ config(materialized="view") }}

{#
  Staging model for the zone-side hub/sat. Adds vault metadata + hash columns:
    - pickup_zone_pk            — hub_pickup_zone business-key hash
    - zone_hashdiff             — sat_zone_details change detection
  Sourced from v_stg_zones (one row per zone), not from the trip-level join,
  so the zone hub/sat is loaded at zone grain and the satellite's hashdiff
  reflects zone-level changes (e.g. TLC zone renames), not trip-level churn.
#}
{{
    automate_dv.stage(
        include_source_columns=true,
        source_model="v_stg_zones",
        derived_columns={
            "load_datetime": "current_timestamp()",
            "record_source": "'NYC_TAXI_ZONES'",
        },
        hashed_columns={
            "pickup_zone_pk": "pickup_location_id",
            "zone_hashdiff": {
                "is_hashdiff": true,
                "columns": ["zone_name", "borough"],
            },
        },
    )
}}
