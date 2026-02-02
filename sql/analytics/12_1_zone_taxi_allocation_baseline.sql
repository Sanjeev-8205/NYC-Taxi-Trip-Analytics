--zone_and_time_decision_baseline.sql
--Purpose: To allocate 100 taxis to best zones during high priority hours.
--Grain: 1 row per unique combination of pickup_zone_name and zone_clusters
--Source: mart.fct_zone_efficiency and mart.fct_hourly_demand
--Note:
-- -This is a two stage framework.
-- -The clusters are derived by using the zone efficiency table and the priority hours are derived from the hourly demand table seperately.
-- -Both these results are cross joined to get the main output.
-- -This is a baseline which uses city wide priority hour. Due to this, the (zone x hour) level priority hours are not even accurate and performs really worse. 
-- -Hence, considering this limitation, regard this as just a baseline.
-- -A different sql query is built which contains zone x hour level priority hours which is more consistent and accurate.

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.zone_and_time_decision_baseline` AS
WITH zone_metrics AS(
  SELECT
    pickup_zone_name,
    SUM(total_trips) AS total_trips,
    SAFE_DIVIDE(SUM(total_revenue), SUM(total_trip_duration_minutes)) AS revenue_per_minute,
    SAFE_DIVIDE(SUM(total_trip_duration_minutes),SUM(total_trips))  AS total_trip_duration_minutes
  FROM `nyc-taxi-485918.mart.fct_zone_efficiency`
  GROUP BY pickup_zone_name
),
thresholds AS(
  SELECT
      APPROX_QUANTILES(total_trips,100)[OFFSET(80)] AS p80_trips,
      APPROX_QUANTILES(total_trips,100)[OFFSET(50)] AS p50_trips,
      APPROX_QUANTILES(revenue_per_minute,100)[OFFSET(80)] AS p80_revenue,
      APPROX_QUANTILES(revenue_per_minute,100)[OFFSET(50)] AS p50_revenue,
      APPROX_QUANTILES(total_trip_duration_minutes,100)[OFFSET(80)] AS p80_duration,
      APPROX_QUANTILES(total_trip_duration_minutes,100)[OFFSET(50)] AS p50_duration
    FROM zone_metrics AS z
),
aggs_classified AS(
  SELECT
    *,
    CASE
      WHEN total_trips>=p80_trips THEN 'High'
      WHEN total_trips>=p50_trips AND total_trips<p80_trips THEN 'Medium'
      WHEN total_trips<p50_trips THEN 'Low'
    END AS trip_count,
    CASE
      WHEN revenue_per_minute>=p80_revenue THEN 'High'
      WHEN revenue_per_minute>=p50_revenue AND revenue_per_minute<p80_revenue THEN 'Medium'
      WHEN revenue_per_minute<p50_revenue THEN 'Low'
    END AS revenue_status,
    CASE
      WHEN total_trip_duration_minutes>=p80_duration THEN 'High'
      WHEN total_trip_duration_minutes>=p50_duration AND total_trip_duration_minutes<p80_duration THEN 'Medium'
      WHEN total_trip_duration_minutes<p50_duration THEN 'Low'
    END AS duration
  FROM zone_metrics z
  CROSS JOIN thresholds t
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
    END AS zone_clusters,
  FROM aggs_classified
),
hourly_demand AS(
  SELECT
    pickup_hour AS hour_of_day,
    AVG(total_trip) AS avg_trips,
    STDDEV(total_trip) AS trip_volatility
  FROM `nyc-taxi-485918.mart.fct_hourly_demand`
  GROUP BY hour_of_day
),
hour_metric_thresholds AS(
  SELECT
    APPROX_QUANTILES(avg_trips,100)[OFFSET(80)] AS high_trip_count,
    APPROX_QUANTILES(trip_volatility,100)[OFFSET(80)] AS high_trip_volatility
  FROM hourly_demand
),
priority_hours AS(
  SELECT
    hour_of_day,
    CASE 
      WHEN avg_trips>=high_trip_count AND trip_volatility>=high_trip_volatility THEN 'High Priority'
      ELSE 'Normal'
    END AS hour_priority,
    avg_trips, trip_volatility
  FROM hourly_demand hd
  CROSS JOIN hour_metric_thresholds h
)
SELECT
  c.pickup_zone_name,
  c.zone_clusters,
  p.hour_of_day,
  p.hour_priority
FROM clusters c
CROSS JOIN priority_hours AS p
WHERE zone_clusters IS NOT NULL AND p.hour_priority='High Priority' AND zone_clusters IN('Efficiency-driven','High-demand High-priority')
ORDER BY pickup_zone_name, hour_of_day
