{{ config(materialized="view") }}

with
    src as (select * from {{ source("carto_nyc_taxi", "tlc_trip_records") }}),

    renamed as (
        select
            cast(vendor_id as varchar) as vendor_id,
            cast(pickup_datetime as timestamp_ntz) as pickup_datetime,
            cast(dropoff_datetime as timestamp_ntz) as dropoff_datetime,
            cast(pickup_longitude as float) as pickup_longitude,
            cast(pickup_latitude as float) as pickup_latitude,
            cast(dropoff_longitude as float) as dropoff_longitude,
            cast(dropoff_latitude as float) as dropoff_latitude,
            cast(passenger_count as integer) as passenger_count,
            cast(trip_distance as numeric(10, 3)) as trip_distance_miles,
            cast(payment_type as varchar) as payment_type,
            cast(fare_amount as numeric(10, 2)) as fare_amount,
            cast(tip_amount as numeric(10, 2)) as tip_amount,
            cast(tolls_amount as numeric(10, 2)) as tolls_amount,
            cast(total_amount as numeric(10, 2)) as total_amount,
            'CARTO_NYC_TAXI' as record_source
        from src
    )

select *
from renamed
