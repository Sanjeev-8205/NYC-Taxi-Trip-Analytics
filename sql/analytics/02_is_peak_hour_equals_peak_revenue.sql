--is_peak_hours_equals_peak_revenue.sql
--Purpose: To check if the peak trip hours also have peak revenue.
--Grain: 1 row per unique combination of pickup_date,pickup_hour
--Source: `mart.fct_hourly_demand`
--Note: Group by week,pickup_hours to see the difference between weekdays and weekends

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.is_peak_hr_equals_peak_revenue` AS
WITH base AS(
  SELECT
    pickup_date,
    CASE
      WHEN pickup_weekday BETWEEN 1 and 5 THEN 'weekday'
      WHEN pickup_weekday BETWEEN 6 and 7 THEN 'weekend'
    END AS week,
    pickup_hour,
    total_revenue,
    total_trip,
    MAX(total_revenue) OVER(partition by pickup_date) AS max_total_revenue,
    MAX(total_trip) OVER(partition by pickup_date) AS max_trip
  FROM `nyc-taxi-485918.mart.fct_hourly_demand` AS hd
)
SELECT
  * EXCEPT(max_total_revenue, max_trip)
FROM base
WHERE total_trip>=0.8*max_trip AND total_revenue>=0.8*max_total_revenue
