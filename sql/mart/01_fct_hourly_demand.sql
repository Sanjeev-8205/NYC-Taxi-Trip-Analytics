--01_fct_hourly_demand.sql
--Purpose: To understand the hourly demand of the neywork taxi in 2021.
--Grain: 1 row per unique pickup_date, pickup_hour combination
--Source: stg.events

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_hourly_demand` AS
SELECT
  pickup_date,
  pickup_hour,
  COUNT(*) AS total_trip,
  SUM(total_amount) AS total_revenue,
  AVG(fare_amount) AS avg_fare,
  AVG(trip_duration_minutes) AS avg_trip_duration,
  AVG(trip_distance) AS avg_trip_distance
FROM `nyc-taxi-485918.stg.events`
GROUP BY pickup_date, pickup_hour
