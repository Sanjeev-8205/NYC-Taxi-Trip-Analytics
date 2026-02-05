--05_fct_zone_hourly_efficiency.sql
--Purpose: To aggregate the zone's hourly efficiency.
--Grain: 1 row per unique combination of pickup_zone_name, pickup_hour, day_of_week
--Source: stg.events_view_dedup
--Note: 
-- -The need for this mart table arised after the worst results obtained from the taxi allocation baseline.
-- -Furthermore, the 2nd version produced better taxi allocation results due to (zone x hour) level grain.
-- -THis table can also be used for building machine learning model to predict the total trips.

CREATE OR REPLACE TABLE `nyc-taxi-485918.mart.fct_zone_hourly_efficiency` AS
SELECT
  pickup_zone_name,
  pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_date) AS day_of_week,
  COUNT(*) AS total_trip,
  SUM(total_amount) AS total_revenue,
  SUM(trip_distance) AS total_distance,
  SUM(trip_duration_minutes) AS trip_duration,
  SAFE_DIVIDE(SUM(total_amount), SUM(trip_duration_minutes)) AS revenue_per_minute,
  SAFE_DIVIDE(SUM(trip_duration_minutes), COUNT(*)) AS avg_trip_duration
FROM `nyc-taxi-485918.stg.events_view_dedup`
GROUP BY pickup_zone_name, pickup_hour, day_of_week
