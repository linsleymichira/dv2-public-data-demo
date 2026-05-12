{{ config(materialized="incremental") }}

{{
    automate_dv.hub(
        src_pk="pickup_zone_pk",
        src_nk="pickup_location_id",
        src_ldts="load_datetime",
        src_source="record_source",
        source_model="stg_zones_hashed",
    )
}}
