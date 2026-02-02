--zone_clusters.sql
--Purpose: To cluster the zones based on demand, efficiency and congestion.
--Grain: 1 row unique pickup_zone_name
--Source: mart.fct_zone_efficiency
--Note: This is the unfiltered query i.e., not filtering out the Non-Actionable cluster.

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.zone_clusters` AS
WITH source_zone_efficiency AS(
  SELECT
    pickup_zone_name,
    SUM(total_trips) AS total_trips,
    SUM(total_revenue) AS total_revenue,
    SUM(total_trip_duration_minutes) AS total_trip_duration_minutes,
    SUM(total_trip_distance) AS total_trip_distance
  FROM `nyc-taxi-485918.mart.fct_zone_efficiency`
  GROUP BY pickup_zone_name
),
aggs AS(
  SELECT
    *,
    SAFE_DIVIDE(SUM(total_revenue) OVER(partition by pickup_zone_name), SUM(total_trips) OVER(partition by pickup_zone_name)) AS revenue_per_trip,
    SAFE_DIVIDE(SUM(total_revenue) OVER(partition by pickup_zone_name), SUM(total_trip_duration_minutes) OVER(partition by pickup_zone_name)) AS revenue_per_minute,
    SAFE_DIVIDE(SUM(total_revenue) OVER(partition by pickup_zone_name), SUM(total_trip_distance) OVER(partition by pickup_zone_name)) AS revenue_per_mile,
    SAFE_DIVIDE(SUM(total_trip_duration_minutes) OVER(partition by pickup_zone_name), SUM(total_trips) OVER(partition by pickup_zone_name)) AS avg_trip_duration
  FROM source_zone_efficiency
),
thresholds AS(
  SELECT
    APPROX_QUANTILES(total_trips,100)[OFFSET(80)] AS high_thres_trip,
    APPROX_QUANTILES(total_trips,100)[OFFSET(50)] AS med_thres_trip,
    APPROX_QUANTILES(revenue_per_minute,100)[OFFSET(80)] AS high_thres_revenue_per_minute,
    APPROX_QUANTILES(revenue_per_minute,100)[OFFSET(50)] AS med_thres_revenue_per_minute,
    APPROX_QUANTILES(avg_trip_duration,100)[OFFSET(80)] AS high_thres_avg_trip_duration,
    APPROX_QUANTILES(avg_trip_duration,100)[OFFSET(50)] AS med_thres_avg_trip_duration
  FROM aggs
),
demand_eff_cong AS(
  SELECT
    a.pickup_zone_name,
    a.total_trips,
    a.revenue_per_minute,
    a.avg_trip_duration,
    CASE
      WHEN total_trips>high_thres_trip THEN 'High'
      WHEN total_trips>=med_thres_trip AND total_trips<high_thres_trip THEN 'Medium'
      ELSE 'Low'
    END AS demand_status,
    CASE
      WHEN revenue_per_minute>high_thres_revenue_per_minute THEN 'High'
      WHEN revenue_per_minute>=med_thres_revenue_per_minute AND revenue_per_minute<high_thres_revenue_per_minute THEN 'Medium'
      ELSE 'Low'
    END AS efficiency_status,
    CASE
      WHEN avg_trip_duration>high_thres_avg_trip_duration THEN 'High'
      WHEN avg_trip_duration>=med_thres_avg_trip_duration AND avg_trip_duration<high_thres_avg_trip_duration THEN 'Medium'
      ELSE 'Low'
    END AS congestion_status,
  FROM aggs a
  CROSS JOIN thresholds t
)
SELECT
  pickup_zone_name,
  CASE
    WHEN demand_status IN('Low','Medium') AND efficiency_status='High' AND congestion_status IN('Low',"Medium") THEN
    'Efficiency-Driven'
    WHEN demand_status='High' AND efficiency_status='Low' AND congestion_status='High' THEN 'Demand-driven but inefficient'
    WHEN demand_status IN('Medium') AND efficiency_status IN('High','Medium') AND congestion_status IN("Medium") THEN
    'Balanced/Healthy zones'
    WHEN demand_status IN('Low') AND efficiency_status='Low' AND congestion_status IN('Low') THEN
    'Overserved/Low-Value zones'
    WHEN demand_status='High' AND efficiency_status='High' AND congestion_status='Low' THEN 'High-Demand High-Efficiency'
    ELSE 'Non-Actionable'
  END AS cluster,
  demand_status,
  efficiency_status,
  congestion_status,
  total_trips,
  revenue_per_minute,
  avg_trip_duration
FROM demand_eff_cong
