{{ config(materialized="table") }}

{#
  Per-trip derived metrics. Reads from the hashed staging model so the join
  keys (vendor_pk, pickup_zone_pk) are pre-computed and downstream marts can
  join cleanly to hub_vendor / hub_pickup_zone.

  Scope note: in a fuller vault implementation, this would feed off a
  transactional satellite (sat_trip_transactions) keyed off a hub_trip. For
  the smallest-defensible MVP we don't materialize trip-grain in the vault
  itself, so bv_trip_metrics reads from the hashed staging layer instead.
#}
with
    src as (select * from {{ ref("stg_trips_hashed") }}),

    metrics as (
        select
            vendor_pk,
            pickup_zone_pk,
            link_vendor_zone_pk,
            vendor_id,
            pickup_location_id,
            pickup_datetime,
            dropoff_datetime,
            trip_distance_miles,
            fare_amount,
            tip_amount,
            total_amount,

            -- safe-divide tip percentage; null when fare is zero or negative
            cast(null as boolean) as is_peak_hour,

            -- safe-divide fare per mile; null when distance is zero or negative
            cast(null as boolean) as is_long_trip,

            -- TODO(human) — peak-hour + long-trip thresholds.
            -- These two flags drive every "rush-hour spike" and "outlier trip"
            -- segmentation downstream. The choices encode real business judgment:
            -- • is_peak_hour: NYC TLC commonly defines weekday 7–10am + 4–8pm
            -- as peak. Do you want that, or a different definition (e.g.
            -- just evening rush, or weekend nights too)?
            -- • is_long_trip: TLC's 75th percentile trip is roughly 2.5 miles.
            -- Is "long" >= 5 miles, >= 10 miles, or a quantile-based cutoff?
            -- Replace the two `null` lines below with case expressions on
            -- pickup_datetime (use hour() / dayofweek()) and trip_distance_miles.
            load_datetime,
            record_source,

            case
                when fare_amount > 0 then round(tip_amount / fare_amount, 4)
            end as tip_pct,
            case
                when trip_distance_miles > 0
                then round(fare_amount / trip_distance_miles, 4)
            end as fare_per_mile
        from src
    )

select *
from metrics
