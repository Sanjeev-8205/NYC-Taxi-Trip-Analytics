--distance_buckets_revenue_outliers.sql
--Purpose: To aggregate the avg revenue and std deviation revenue for each bucket and then use them to find the outliers.
--Grain: 1 row per unique combination of buckets, pickup_zone_name
--Source: mart.fct_trip_distribution
--Note: Used 1.5 during outlier calculation since 2.0 can skip out the important outliers

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.distance_buckets_revenue_outliers` AS
WITH source_trip_distribution AS(
  SELECT
    buckets,
    pickup_zone_name,
    avg_revenue
  FROM `nyc-taxi-485918.mart.fct_trip_distribution`
),
statistics AS(
  SELECT
    *,
    AVG(avg_revenue) OVER(partition by buckets) avg_rev_per_bucket,
    STDDEV(avg_revenue) OVER(partition by buckets) std_rev_per_bucket
  FROM source_trip_distribution
)
SELECT
  buckets,
  pickup_zone_name,
  avg_revenue,
  CASE
    WHEN avg_revenue<avg_rev_per_bucket - 1.5*std_rev_per_bucket THEN 'Low Outlier'
    WHEN avg_revenue>avg_rev_per_bucket + 1.5*std_rev_per_bucket THEN 'High Outlier'
    ELSE 'Normal'
  END AS outlier_flag
FROM statistics
