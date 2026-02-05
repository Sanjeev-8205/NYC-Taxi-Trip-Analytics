-- 06_metric_negative_records_check.sql

-- CONTRACT:
-- Core aggregated metrics must never be negative.
-- Any violation indicates issues in aggregation ore modeling.
-- The affected records are excluded from the results.
-- This is expected to return 0 rows.

-- REQUIRED INPUTS:
-- table: mart.fct_hourly_demand
-- critical_columns: total_revenue, avg_fare, avg_trip_duration, avg_trip_distance

SELECT
  COUNTIF(total_revenue<0) AS negative_revenue,
  COUNTIF(avg_fare<0) AS negative_fare,
  COUNTIF(avg_trip_duration<0) AS negative_duration,
  COUNTIF(avg_trip_distance<0) AS negative_duration
FROM `nyc-taxi-485918.mart.fct_hourly_demand`
