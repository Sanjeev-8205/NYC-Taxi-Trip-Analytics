-- 05_metric_zero_activity_and_null_trips_check.sql

-- CONTRACT:
-- Trips must be greater than zero and non-null.
-- Any violation indicates issues in aggregation or modeling.
-- Tha affected records are excluded from the downstream marts and the issue is documented.

-- REQUIRED INPUTS:
-- table: stg.events_view_dedup
-- critical_column: total_trip

SELECT
  COUNTIF(total_trip=0) AS zero_activity,
  COUNTIF(total_trip IS NULL) AS null_trips
FROM `nyc-taxi-485918.mart.fct_hourly_demand`
