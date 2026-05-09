{{ config(materialized="table") }}

{#
  Flat, BI-friendly daily fact at vendor × pickup_zone grain.
  Joins the raw vault (hubs + current sat snapshots) and the business vault
  (per-trip metrics) so consumers don't have to navigate hub/link/sat
  themselves. This is the only model BI tools should read.
#}
with
    current_vendor as (
        select vendor_pk, vendor_label
        from {{ ref("sat_vendor_details") }}
        qualify
            row_number() over (partition by vendor_pk order by load_datetime desc) = 1
    ),

    current_zone as (
        select pickup_zone_pk, zone_name, borough
        from {{ ref("sat_zone_details") }}
        qualify
            row_number() over (partition by pickup_zone_pk order by load_datetime desc)
            = 1
    ),

    trip_metrics as (select * from {{ ref("bv_trip_metrics") }}),

    daily as (
        select
            cast(t.pickup_datetime as date) as pickup_date,
            t.vendor_pk,
            t.pickup_zone_pk,
            count(*) as trip_count,
            count_if(t.is_peak_hour) as peak_hour_trip_count,
            count_if(t.is_long_trip) as long_trip_count,
            sum(t.fare_amount) as total_fare_amount,
            sum(t.tip_amount) as total_tip_amount,
            sum(t.total_amount) as total_amount,
            avg(t.tip_pct) as avg_tip_pct,
            avg(t.fare_per_mile) as avg_fare_per_mile,
            sum(t.trip_distance_miles) as total_trip_distance_miles
        from trip_metrics as t
        group by 1, 2, 3
    )

select
    d.pickup_date,
    d.vendor_pk,
    v.vendor_label,
    d.pickup_zone_pk,
    z.zone_name as pickup_zone_name,
    z.borough as pickup_borough,
    d.trip_count,
    d.peak_hour_trip_count,
    d.long_trip_count,
    d.total_fare_amount,
    d.total_tip_amount,
    d.total_amount,
    d.avg_tip_pct,
    d.avg_fare_per_mile,
    d.total_trip_distance_miles
from daily as d
left join current_vendor as v on d.vendor_pk = v.vendor_pk
left join current_zone as z on d.pickup_zone_pk = z.pickup_zone_pk
