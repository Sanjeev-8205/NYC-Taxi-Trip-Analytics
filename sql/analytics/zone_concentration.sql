--zone_concentration.sql
--Purpose: TO aggregate the zone concentration.
--Grain: 1 row per unique pickup_zone_name
--Source: mart.fct_zone_daily_performance

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.zone_concentration` AS
WITH base AS(
  SELECT
    DISTINCT pickup_zone_name,
    SUM(total_trips) OVER(partition by pickup_zone_name) AS total_trips_per_zone,
    SUM(total_trips) OVER() AS total_city_trips,
    SAFE_DIVIDE(SUM(total_trips) OVER(partition by pickup_zone_name),SUM(total_trips) OVER())*100 AS zone_concentration_percentage
  FROM `nyc-taxi-485918.mart.fct_zone_daily_performance`
)
SELECT
  *
FROM base
ORDER BY zone_concentration_percentage DESC
