{{ config(materialized='view') }}

with src as (
    select * from {{ source('nyc_taxi_zones', 'taxi_zones') }}
),

renamed as (
    select
        cast(location_id as integer)  as pickup_location_id,
        cast(zone as varchar)         as zone_name,
        cast(borough as varchar)      as borough,
        geom                          as zone_geom,
        'NYC_TAXI_ZONES'              as record_source
    from src
)

select * from renamed
