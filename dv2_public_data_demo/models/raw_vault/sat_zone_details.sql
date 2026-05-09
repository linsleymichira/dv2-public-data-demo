{{ config(materialized="incremental") }}

{{
    automate_dv.sat(
        src_pk="pickup_zone_pk",
        src_hashdiff="zone_hashdiff",
        src_payload=["zone_name", "borough"],
        src_eff="load_datetime",
        src_ldts="load_datetime",
        src_source="record_source",
        source_model="stg_zones_hashed",
    )
}}
