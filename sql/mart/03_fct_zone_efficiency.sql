--03_fct_zone_efficiency.sql
--Purpose: To find the efficiency of the zones.
--Grain: 1 row per unique combination of pickup_zone and pickup_date
--Source: stg.events
--Note: Reflets the effectiveness of each zone in each day using the aggregates.

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_zone_efficiency` AS
SELECT
  pickup_zone_name,
  pickup_date,
  COUNT(*) AS total_trips,
  SUM(total_amount) AS total_revenue,
  SUM(trip_distance) AS total_trip_distance,
  SUM(fare_amount) AS fare_amount,
  SUM(trip_duration_minutes) AS total_trip_duration_minutes,
  AVG(passenger_count) AS avg_passenger_count
FROM `nyc-taxi-485918.stg.events`
GROUP BY pickup_zone_name, pickup_date
