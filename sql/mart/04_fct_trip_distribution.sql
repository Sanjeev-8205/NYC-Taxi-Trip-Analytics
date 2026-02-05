--04_fct_trip_distribution.sql
--Purpose: To find the short-long trips and cheap-expensive trips
--Grain: 1 row per unique combination of buckets, pickup_zone_name
--Source: stg.events_view_dedup

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_trip_distribution` AS
SELECT
  CASE
    WHEN trip_distance>=0 AND trip_distance<1.5 THEN '0-1.5 mile'
    WHEN trip_distance>=1.5 AND trip_distance<4 THEN '1.5-4 miles'
    WHEN trip_distance>=4 AND trip_distance<13 THEN '4-13 miles'
    WHEN trip_distance>=13 THEN '13+ miles'
  END AS buckets,
  pickup_zone_name,
  COUNT(*) AS trip_count,
  AVG(trip_distance) AS avg_trip_distance,
  AVG(total_amount) AS avg_revenue,
  AVG(fare_amount) AS avg_fare,
  AVG(trip_duration_minutes) AS avg_trip_duration_minutes
FROM `nyc-taxi-485918.stg.events_view_dedup`
WHERE trip_distance IS NOT NULL
GROUP BY buckets, pickup_zone_name
