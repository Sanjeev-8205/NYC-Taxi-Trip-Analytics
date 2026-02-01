--03_fct_zone_efficiency.sql
--Purpose: To find the efficiency of the zones.
--Grain: 1 row per unique combination of pickup_zone and pickup_date
--Source: stg.events
--Note: Reflets the effectivesness of each zone in each day using the aggregates.

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_zone_efficiency` AS
SELECT
  pickup_zone_name,
  pickup_date,
  COUNT(*) AS total_trips,
  SAFE_DIVIDE(SUM(total_amount), COUNT(*)) AS revenue_per_trip,
  SAFE_DIVIDE(SUM(total_amount),SUM(trip_distance)) AS revenue_per_mile,
  SAFE_DIVIDE(SUM(fare_amount), SUM(trip_distance)) AS fare_per_miles,
  SAFE_DIVIDE(SUM(total_amount),SUM(trip_duration_minutes)) AS revenue_per_minute,
  AVG(passenger_count) AS avg_passenger_count
FROM `nyc-taxi-485918.stg.events`
GROUP BY pickup_zone_name, pickup_date
