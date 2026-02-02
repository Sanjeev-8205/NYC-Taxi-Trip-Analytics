--low_trips_and_high_revenue_per_trip.sql
--Purpose: To find the zones wher the revenue per trip is very high but the number of trips is low.
--Grain: 1 row unique zone
--Source: mart.fct_zone_efficiency, mart.fct_zone_daily_performance

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.low_trips_and_high_revenue_per_trip` AS
WITH base AS(
  SELECT
    DISTINCT ze.pickup_zone_name,
    SUM(ze.revenue_per_trip) OVER(partition by ze.pickup_zone_name) AS zone_total_revenue,
    SUM(zdp.total_trips) OVER(partition by ze.pickup_zone_name) AS zone_total_trips,
    SAFE_DIVIDE(SUM(ze.revenue_per_trip) OVER(partition by ze.pickup_zone_name), SUM(zdp.total_trips) OVER( partition by ze.pickup_zone_name)) AS zone_revenue_per_trip,
  FROM `nyc-taxi-485918.mart.fct_zone_efficiency` AS ze
  JOIN `nyc-taxi-485918.mart.fct_zone_daily_performance` AS zdp ON ze.pickup_zone_name=zdp.pickup_zone_name AND ze.pickup_date=zdp.pickup_date
),
thresholds AS(
  SELECT
    APPROX_QUANTILES(zone_revenue_per_trip, 100)[OFFSET(90)] rpt_threshold,
    APPROX_QUANTILES(zone_total_trips, 100)[OFFSET(15)] tt_threshold
  FROM base
),
final AS(
  SELECT
    b.*,
    t.rpt_threshold,
    t.tt_threshold
  FROM base AS b
  CROSS JOIN thresholds AS t
  WHERE zone_revenue_per_trip>=t.rpt_threshold AND zone_total_trips<t.tt_threshold
)
SELECT
  pickup_zone_name,
  zone_total_revenue,
  zone_total_trips,
  zone_revenue_per_trip
FROM final
