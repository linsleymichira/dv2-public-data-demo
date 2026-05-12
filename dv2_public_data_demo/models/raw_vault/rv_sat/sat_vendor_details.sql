{{ config(materialized="incremental") }}

{{
    automate_dv.sat(
        src_pk="vendor_pk",
        src_hashdiff="vendor_hashdiff",
        src_payload=["vendor_label"],
        src_eff="load_datetime",
        src_ldts="load_datetime",
        src_source="record_source",
        source_model="stg_trips_hashed",
    )
}}
