{{ config(materialized="incremental") }}

{{
    automate_dv.link(
        src_pk="link_vendor_zone_pk",
        src_fk=["vendor_pk", "pickup_zone_pk"],
        src_ldts="load_datetime",
        src_source="record_source",
        source_model="stg_trips_hashed",
    )
}}
