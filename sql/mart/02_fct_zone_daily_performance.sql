--02_fct_zone_daily_performance.sql
--Purpose: To aggregate the daily zone performance.
--Grain: 1 row per unique pickup_zone_name, pickup_borough, pickup_date combinations
--Source: stg.events
--Note: This mart table is capable of finding the best zones and worst zones based on revenue, total_trips and so on.

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_zone_daily_performance` AS
SELECT
  pickup_zone_name,
  pickup_borough,
  pickup_date,
  COUNT(*) AS total_trips,
  SUM(total_amount) AS total_revenue,
  AVG(fare_amount) AS avg_fare,
  AVG(trip_distance) AS avg_distance,
  AVG(trip_duration_minutes) AS avg_trip_duration,
  COUNT(*)/24 AS trips_per_hour
FROM `nyc-taxi-485918.stg.events`
GROUP BY pickup_zone_name, pickup_borough, pickup_date
