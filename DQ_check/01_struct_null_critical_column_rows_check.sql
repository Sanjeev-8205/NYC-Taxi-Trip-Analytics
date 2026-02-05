-- 01_struct_null_critical_column_rows_check.sql

-- CONTRACT:
-- Critical column must never be null.
-- Any violation indicates upstream ingestion or schema failure.
-- This is expected to return 0 rows.

-- REQUIRED INPUTS:
-- table: stg.events
-- critical_columns: pickup_date, pickup_hour, pickup_weekday, pickup_zone_name, pickup_borough

SELECT
  COUNT(*) AS total_rows,
  COUNTIF(pickup_date IS NULL) AS null_dates,
  COUNTIF(pickup_hour IS NULL) AS null_hours,
  COUNTIF(pickup_weekday IS NULL) AS null_days,
  COUNTIF(pickup_zone_name IS NULL) AS null_zones,
  COUNTIF(pickup_borough IS NULL) AS null_borough  
FROM `nyc-taxi-485918.stg.events`
