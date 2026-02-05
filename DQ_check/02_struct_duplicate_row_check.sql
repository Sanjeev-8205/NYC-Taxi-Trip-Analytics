-- 01_struct_duplicate_row_check.sql

-- CONTRACT:
-- Duplicates must be well within 0.5% of total rows.
-- If any violation occurs, review is required.

-- REQUIRED INPUTS:
-- table: stg.events
-- critical_columns: pickup_datetime, dropoff_datetime, pickup_location_id, dropoff_location_id, trip_distance, total_amount

WITH dup_stats AS(
SELECT
  SUM(row_count) - COUNT(*) AS excess_duplicate_rows
FROM(
  SELECT
    COUNT(*) AS row_count
  FROM `nyc-taxi-485918.stg.events`
  GROUP BY
    pickup_datetime,
    dropoff_datetime,
    pickup_location_id,
    dropoff_location_id,
    trip_distance,
    total_amount
  HAVING COUNT(*) > 1
)
),
total AS(
  SELECT
    COUNT(*) AS total_rows
  FROM `nyc-taxi-485918.stg.events`
)
SELECT
  CASE
  WHEN SAFE_DIVIDE(dup_stats.excess_duplicate_rows,total.total_rows)<=0.005 THEN 'Within Tolerance'
  ELSE 'Review Required'
  END AS dq_status
FROM dup_stats, total;
