-- 07_metrics_negative_revenue_per_minute_check

-- CONTRACT:
-- Revenue per minute can never be negative.
-- Any violation indicates invalid conversion metrics.
-- The affected records are excluded from the table.
-- This row is expected to return zero rows.

-- REQUIRED INPUTS:
-- table:mart.fct_zone_hourly_efficiency
-- critical_column: revenue_per_minute

SELECT
  COUNTIF(revenue_per_minute<0) AS negative_revenue_per_minute
FROm `nyc-taxi-485918.mart.fct_zone_hourly_efficiency`
