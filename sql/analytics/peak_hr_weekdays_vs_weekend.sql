--peak_hr_weekdays_vs_weekend.sql
--Purpose: To find the peak hours of each day and differentitate the peak hours during weekdays and weekends.
--Grain: 1 row per unique combination of pickup_date, pickup_hour
--Source: mart.fct_hourly_demand
--Note: In the main query, group by week, pickup_hour and then using the count function on pickup_hour to find the peak hour trips on weekend and weekdays.

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.peak_hr_weekdays_vs_weekend` AS
WITH base AS(
  SELECT
    pickup_date,
    CASE
      WHEN pickup_weekday BETWEEN 1 and 5 THEN 'weekday'
      WHEN pickup_weekday BETWEEN 6 and 7 THEN 'weekend'
    END AS week,
    pickup_hour,
    total_trip,
    MAX(total_trip) OVER(partition by pickup_date) AS max_trip
  FROM `nyc-taxi-485918.mart.fct_hourly_demand` AS hd
)
SELECT
  * EXCEPT(max_trip)
FROM base
WHERE total_trip>=0.8*max_trip
