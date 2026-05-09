{{ config(materialized="view") }}

{#
  Staging model for the trip-side hubs/links/sats. Adds vault metadata
  (load_datetime, record_source), a derived `vendor_label`, and hash columns:
    - vendor_pk                 — hub_vendor business-key hash
    - pickup_zone_pk            — used as FK from link_vendor_zone
    - link_vendor_zone_pk       — link composite-key hash
    - vendor_hashdiff           — sat_vendor_details change detection
#}
{{
    automate_dv.stage(
        include_source_columns=true,
        source_model="v_stg_trips_with_zones",
        derived_columns={
            "load_datetime": "current_timestamp()",
            "record_source": "'CARTO_NYC_TAXI'",
            "vendor_label": "case vendor_id when '1' then 'CMT' when '2' then 'VTS' else 'OTHER' end",
        },
        hashed_columns={
            "vendor_pk": "vendor_id",
            "pickup_zone_pk": "pickup_location_id",
            "link_vendor_zone_pk": ["vendor_id", "pickup_location_id"],
            "vendor_hashdiff": {"is_hashdiff": true, "columns": ["vendor_label"]},
        },
    )
}}
