--analytics_zone_performance_across_borough_weekday_vs_weekend.sql
--Purpose: To aggregate the performance of the borough between weekday and weekend.
--Grain: 1 row per unique combiantion of pickup_borough, day_type
--Source: mart.fct_zone_daily_performance 

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.zone_performance_across_borough_weekday_vs_weekend` AS
SELECT
  pickup_borough,
  CASE
  WHEN EXTRACT(DAYOFWEEK FROM pickup_date) BETWEEN 1 and 5 THEN 'weekday'
  WHEN EXTRACT(DAYOFWEEK FROM pickup_date) IN(6,7) THEN 'weekend'
  END AS day_type,
  SUM(total_trips) AS borough_total_trip,
  SUM(total_revenue) AS borough_total_revenue,
  AVG(avg_fare) AS avg_fare,
  AVG(avg_distance) AS avg_distance,
  SAFE_DIVIDE(SUM(total_revenue), SUM(total_trips)) AS revenue_per_trip
FROM `nyc-taxi-485918.mart.fct_zone_daily_performance`
GROUP BY pickup_borough, day_type
ORDER BY pickup_borough, day_type
