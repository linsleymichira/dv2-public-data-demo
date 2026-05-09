{{ config(materialized='table') }}

with trips as (
    select * from {{ ref('v_stg_trips') }}
),

zones as (
    select * from {{ ref('v_stg_zones') }}
),

{#
  TODO(human) — coord validity filter.
  CARTO 2014–2015 trips include rows with (0, 0) and out-of-NYC coordinates that will
  silently fall outside every zone polygon and get a NULL pickup_location_id. Decide:
    1. Do we keep those rows with a NULL pickup_location_id (and document that hubs
       only ingest non-null keys), or filter them in this CTE?
    2. If filtering, what's the bounding box? NYC roughly spans
       longitude (-74.30, -73.65) and latitude (40.45, 40.95). Tighter or looser?
    3. Add an `is_inside_nyc` boolean column for inspection, or fully drop bad rows?
  Replace this comment with a `valid_trips as (...)` CTE and update the geo_joined
  CTE below to read from it. 5–10 lines is plenty.
#}
valid_trips as (
    select * from trips
    -- replace this passthrough once the filter strategy above is decided
),

geo_joined as (
    select
        t.*,
        z.pickup_location_id,
        z.zone_name as pickup_zone_name,
        z.borough   as pickup_borough
    from valid_trips t
    left join zones z
        on st_contains(z.zone_geom, st_makepoint(t.pickup_longitude, t.pickup_latitude))
)

select * from geo_joined
