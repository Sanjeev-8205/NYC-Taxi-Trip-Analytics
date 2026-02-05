-- 04_metric_negative_count_check.sql

-- CONTRACT:
-- Core metrics must never be negative(>=0).
-- Any violation indicates issues in aggregation or modeling.
-- Affect records are excluded from downstream marts and the issue is documented.

-- REQUIRED INPUTS:
-- table: stg.events
-- critical_columns: trip_duration_minutes, trip_distance, total_amount

SELECT
  COUNTIF(trip_duration_minutes<0) AS negative_durations,
  COUNTIF(trip_distance<0) AS negative_distances,
  COUNTIF(total_amount<0) AS negative_revenues
FROM `nyc-taxi-485918.stg.events`
