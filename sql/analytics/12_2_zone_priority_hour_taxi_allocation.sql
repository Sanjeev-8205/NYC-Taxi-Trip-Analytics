--zone_priority_hour_taxi_allocation.sql
--Purpose: To allocate 100 taxis to the eligible zones during high priority hours.
--Grain: 1 row per unique combination of pickup_zone_name, clusters, pickup_hour
--Source: mart.fct_zone_hourly_efficiency
--Note: The allocation was decided by using hourly trips demand weight.

WITH zone_hourly_metrics AS(
  SELECT
    pickup_zone_name,
    pickup_hour,
    SUM(total_trip) AS total_trip,
    SUM(total_revenue) AS total_revenue,
    SUM(trip_duration) AS trip_duration,
    SAFE_DIVIDE(SUM(total_revenue), SUM(trip_duration)) AS revenue_per_minute,
    SAFE_DIVIDE(SUM(trip_duration), SUM(total_trip)) AS avg_trip_duration,
    AVG(total_trip) AS avg_trip,
    STDDEV(total_trip) AS trip_volatility
  FROM `nyc-taxi-485918.mart.fct_zone_hourly_efficiency`
  GROUP BY pickup_zone_name, pickup_hour
),
threshold AS(
  SELECT
    APPROX_QUANTILES(avg_trip, 100)[OFFSET(80)] AS p80_avg_trip,
    APPROX_QUANTILES(trip_volatility, 100)[OFFSET(80)] AS p80_trip_volatility
  FROM zone_hourly_metrics
),
priority_hour AS(
  SELECT
    pickup_zone_name,
    pickup_hour,
    total_trip AS hourly_trips,
    CASE
      WHEN avg_trip>=p80_avg_trip AND trip_volatility>=p80_trip_volatility THEN 'High Priority'
      ELSE 'Normal'
    END AS hour_priority
  FROM zone_hourly_metrics
  CROSS JOIN threshold t
),
zone_level_metrics AS(
  SELECT
    pickup_zone_name,
    SUM(total_trip) AS total_trip,
    SUM(total_revenue) AS total_revenue,
    SUM(trip_duration) AS trip_duration,
    SAFE_DIVIDE(SUM(total_revenue), SUM(trip_duration)) AS revenue_per_minute,
    SAFE_DIVIDE(SUM(trip_duration), SUM(total_trip)) AS avg_trip_duration,
  FROM `nyc-taxi-485918.mart.fct_zone_hourly_efficiency`
  GROUP BY pickup_zone_name
),
threshold_zone AS(
  SELECT
    APPROX_QUANTILES(total_trip, 100)[OFFSET(80)] AS p80_trip,
    APPROX_QUANTILES(total_trip, 100)[OFFSET(50)] AS p50_trip,
    APPROX_QUANTILES(revenue_per_minute, 100)[OFFSET(80)] AS p80_rpm,
    APPROX_QUANTILES(revenue_per_minute, 100)[OFFSET(50)] AS p50_rpm,
    APPROX_QUANTILES(avg_trip_duration, 100)[OFFSET(80)] AS p80_atd,
    APPROX_QUANTILES(avg_trip_duration, 100)[OFFSET(50)] AS p50_atd,
  FROM zone_level_metrics
),
aggs_classified AS(
  SELECT
    *,
    CASE 
      WHEN total_trip>=p80_trip THEN 'High'
      WHEN total_trip>=p50_trip AND total_trip<p80_trip THEN 'Medium'
      WHEN total_trip<p50_trip THEN 'Low'
    END AS trip_count,
    CASE 
      WHEN revenue_per_minute>=p80_rpm THEN 'High'
      WHEN revenue_per_minute>=p50_rpm AND revenue_per_minute<p80_rpm THEN 'Medium'
      WHEN revenue_per_minute<p50_rpm THEN 'Low'
    END AS revenue_status,
    CASE 
      WHEN avg_trip_duration>=p80_atd THEN 'High'
      WHEN avg_trip_duration>=p50_atd AND avg_trip_duration<p80_atd THEN 'Medium'
      WHEN avg_trip_duration<p50_atd THEN 'Low'
    END AS duration
  FROM zone_level_metrics z
  CROSS JOIN threshold_zone tz
),
clusters AS(
  SELECT
    pickup_zone_name,
    CASE
      WHEN trip_count IN('Low','Medium') AND revenue_status='High' AND duration IN('Low','Medium') THEN 'Efficiency-driven'
      WHEN trip_count='High' AND revenue_status='Low' AND duration='High' THEN 'Demand-driven but inefficient'
      WHEN trip_count='Medium' AND revenue_status IN('Medium','High') AND duration='Medium' THEN 'Balanced'
      WHEN trip_count IN('Low') AND revenue_status='Low' AND duration IN('Low') THEN 'Overserved'
      WHEN trip_count='High' AND revenue_status='High' AND duration='Low' THEN 'High-demand High-efficiency'
      ELSE 'Non-Actionable'
    END AS zone_clusters
  FROM aggs_classified
),
eligible_zone_hours AS(
  SELECT
    c.pickup_zone_name,
    c.zone_clusters,
    p.pickup_hour,
    p.hourly_trips,
    p.hour_priority
  FROM clusters c
  JOIN priority_hour p ON c.pickup_zone_name=p.pickup_zone_name
  WHERE c.zone_clusters IN('Efficiency-driven','High_demand High-efficiency') AND p.hour_priority='High Priority'
),
allocation_zone AS(
  SELECT
    pickup_zone_name,
    zone_clusters,
    pickup_hour,
    hourly_trips,
    hour_priority,
    SAFE_DIVIDE(hourly_trips, SUM(hourly_trips) OVER()) AS demand_weight,
    ROUND(SAFE_DIVIDE(hourly_trips, SUM(hourly_trips) OVER())*100) AS allocated_taxis 
  FROM eligible_zone_hours
)
SELECT
  pickup_zone_name,
  zone_clusters,
  pickup_hour,
  hourly_trips,
  hour_priority,
  demand_weight,
  allocated_taxis
FROM allocation_zone
ORDER BY allocated_taxis DESC
