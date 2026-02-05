-- 03_metric_null_counts_check.sql

-- CONTRACT:
-- Main metric columns must never be null.
-- Violations indicate an aggregation or modeling issue, affected records are excluded from downstream marts and the issue is documented.

-- REQUIRED INPUTS:
-- table: stg.events
-- critical_columns: trip_duration_minutes, trip_distance, total_amoun

SELECT
  COUNTIF(trip_duration_minutes IS NULL) AS null_durations,
  COUNTIF(trip_distance IS NULL) AS null_distances,
  COUNTIF(total_amount IS NULL) AS null_revenues
FROM `nyc-taxi-485918.stg.events`
