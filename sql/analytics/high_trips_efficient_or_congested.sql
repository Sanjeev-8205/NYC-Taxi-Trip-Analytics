--high_trips_efficient_or_congested.sql
--Purpose: To verify if high trip counts are producing efficient revenue or are congested by long durations
--Grain: 1 row unique picku_zone_name
--Source: mart.fct_zone_efficiency

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.high_trips_efficient_or_congested` AS
WITH base AS(
  SELECT
    pickup_zone_name,
    SUM(total_trips) AS total_trips,
    SAFE_DIVIDE(SUM(total_revenue),SUM(total_trip_duration_minutes)) AS revenue_per_minute,
    SUM(total_trip_duration_minutes) AS trip_duration
  FROM `nyc-taxi-485918.mart.fct_zone_efficiency`
  GROUP BY pickup_zone_name
  ORDER BY revenue_per_minute DESC
),
threshold_agg AS(
  SELECT
    APPROX_QUANTILES(total_trips, 100)[OFFSET(80)] AS trips_high_thres,
    APPROX_QUANTILES(revenue_per_minute, 100)[OFFSET(80)] AS revenue_high_thres,
    APPROX_QUANTILES(trip_duration, 100)[OFFSET(80)] AS duration_high_thres,
    APPROX_QUANTILES(total_trips, 100)[OFFSET(50)] AS trips_med_thres,
    APPROX_QUANTILES(revenue_per_minute, 100)[OFFSET(50)] AS revenue_med_thres,
    APPROX_QUANTILES(trip_duration, 100)[OFFSET(50)] AS duration_med_thres,
  FROM base
),
final AS(
SELECT
  b.*,
  CASE
    WHEN total_trips>=trips_high_thres THEN 'HIGH'
    WHEN total_trips>=trips_med_thres AND total_trips<trips_high_thres THEN 'MEDIUM'
    ELSE 'LOW'
  END AS trip_count,
  CASE
    WHEN revenue_per_minute>=revenue_high_thres THEN 'HIGH'
    WHEN revenue_per_minute>=revenue_med_thres AND revenue_per_minute<revenue_high_thres THEN 'MEDIUM'
    ELSE 'LOW'
  END AS revenue_status,
  CASE
    WHEN trip_duration>=duration_high_thres THEN 'HIGH'
    WHEN trip_duration>=duration_med_thres AND trip_duration<duration_high_thres THEN 'MEDIUM'
    ELSE 'LOW'
  END AS duration_status,
FROM base AS b
CROSS JOIN threshold_agg AS t
)
SELECT
  *,
  CASE
    WHEN trip_count='HIGH' AND revenue_status='HIGH' AND duration_status='HIGH' THEN 'High-demand, time-intensive'
    WHEN trip_count='HIGH' AND revenue_status='HIGH' AND duration_status='LOW' THEN 'Optimal high-demand zone'
    WHEN trip_count='HIGH' AND revenue_status='LOW' AND duration_status='HIGH' THEN 'Congested: high demand, low time efficiency'
    WHEN trip_count='HIGH' AND revenue_status='LOW' AND duration_status='MEDIUM' THEN 'Underpriced / inefficient high-demand zone'
    ELSE 'Others'
  END AS congestion_efficiency
FROM final
WHERE trip_count='HIGH'
