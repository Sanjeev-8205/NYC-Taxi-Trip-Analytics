--zone_trip_distribution.sql
--Purpose: To aggregate the distance status for each pickup_zone and find which distances status is responsible for high revenue in that zone.
--Grain: 1 row per unique pickup_zone_name and buckets
--Source: mart.fct_trip_distribution
--Note: Only high rev_status is used since it is the most efficient way to find the high revenue preffered distances for the respective zone.

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.zone_trip_distribution` AS
WITH base AS(
  SELECT
    pickup_zone_name,
    buckets,
    trip_count,
    avg_revenue,
    CASE
      WHEN buckets='0-1.5 mile' THEN 'Very low'
      WHEN buckets='1.5-4 miles' THEN 'Low'
      WHEN buckets='4-13 miles' THEN 'Medium'
      WHEN buckets='13+ miles' THEN 'High'
    END AS distance_status,
  FROM `nyc-taxi-485918.mart.fct_trip_distribution`
  ORDER BY pickup_zone_name 
),
thresholds AS(
  SELECT
    APPROX_QUANTILES(avg_revenue, 100)[OFFSET(80)] AS high_rev,
    APPROX_QUANTILES(avg_revenue, 100)[OFFSET(50)] AS med_rev
  FROM base
),
final AS(
  SELECT
    b.*,
    CASE
      WHEN avg_revenue>=high_rev THEN 'High'
      WHEN avg_revenue>=med_rev AND avg_revenue<high_rev THEN 'Medium'
      WHEN avg_revenue<med_rev THEN 'Low' 
    END AS rev_status
  FROM base b
  CROSS JOIN thresholds t
)
SELECT * FROM final
WHERE rev_status='High'
