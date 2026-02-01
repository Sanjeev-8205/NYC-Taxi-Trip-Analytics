--zone_revenue_per_mile.sql
--Purpose: To aggregate the zone level revenue per mile.
--Grain: 1 row unique pickup_zone_name
--Source:mart.fct_zone_efficiency

SELECT
  pickup_zone_name,
  SUM(total_trips) AS total_trips,
  SAFE_DIVIDE(SUM(total_revenue), SUM(total_trip_distance)) AS  revenue_per_mile,
  SAFE_DIVIDE(SUM(total_revenue), SUM(total_trips)) AS revenue_per_trip
FROM `nyc-taxi-485918.mart.fct_zone_efficiency`
GROUP BY pickup_zone_name
