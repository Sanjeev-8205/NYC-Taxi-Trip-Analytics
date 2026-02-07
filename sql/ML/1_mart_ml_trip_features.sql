-- 1_mart_ml_trip_features.sql
-- Purpose: To create a mart table for predicting total_trips using regression model.
-- Grain: 1 row per unique combination pickup_zone_name, pickup_date, pickup_hour, pickup_weekday
-- Source: stg.events_view_dedup
-- Note: This is expected to be used only by the models.

CREATE OR REPLACE TABLE `nyc-taxi-485918.ML.mart_ml_trip_features` AS
WITH trip_agg AS(
  SELECT
    pickup_zone_name,
    pickup_date,
    pickup_hour,
    pickup_weekday,
    COUNT(*) AS total_trip
  FROM `nyc-taxi-485918.stg.events_view_dedup`
  GROUP BY pickup_zone_name, pickup_date, pickup_hour, pickup_weekday
)
SELECT
  *,
   --Lag Features
  LAG(total_trip,1) OVER w AS lag_1h,
  LAG(total_trip,24) OVER w AS lag_24h,
  LAG(total_trip,168) OVER w AS lag_7d,

  --Rolling Features
  AVG(total_trip) OVER w_24h AS avg_24h,
  AVG(total_trip) OVER w_7d AS avg_7d,
FROM trip_agg
WINDOW
  w AS (
    PARTITION BY pickup_zone_name
    ORDER BY pickup_date, pickup_hour
  ),
  w_24h AS(
    PARTITION BY pickup_zone_name
    ORDER BY pickup_date, pickup_hour
    ROWS BETWEEN 24 PRECEDING AND 1 PRECEDING
  ),
  w_7d AS(
    PARTITION BY pickup_zone_name
    ORDER BY pickup_date, pickup_hour
    ROWS BETWEEN 168 PRECEDING AND 1 PRECEDING
  )
