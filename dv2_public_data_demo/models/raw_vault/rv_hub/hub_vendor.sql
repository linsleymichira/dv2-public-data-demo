{{ config(materialized="incremental") }}

{{
    automate_dv.hub(
        src_pk="vendor_pk",
        src_nk="vendor_id",
        src_ldts="load_datetime",
        src_source="record_source",
        source_model="stg_trips_hashed",
    )
}}
