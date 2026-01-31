--04_fct_trip_distribution.sql
--Purpose: To find the short-long trips and cheap-expensive trips
--Grain: 1 row per unique combination of buckets, pickup_zone_name
--Source: stg.events

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_trip_distribution` AS
SELECT
  CASE
    WHEN trip_distance>=0 AND trip_distance<1 THEN '0-1 mile'
    WHEN trip_distance>=1 AND trip_distance<3 THEN '1-3 miles'
    WHEN trip_distance>=3 AND trip_distance<5 THEN '3-5 miles'
    WHEN trip_distance>=5 AND trip_distance<10 THEN '5-10 miles'
    WHEN trip_distance>=10 THEN '10+ miles'
  END AS buckets,
  pickup_zone_name,
  COUNT(*) AS trip_count,
  AVG(total_amount) AS avg_revenue,
  AVG(fare_amount) AS avg_fare,
  AVG(trip_duration_minutes) AS avg_trip_duration_minutes
FROM `nyc-taxi-485918.stg.events`
WHERE trip_distance IS NOT NULL
GROUP BY buckets, pickup_zone_name
