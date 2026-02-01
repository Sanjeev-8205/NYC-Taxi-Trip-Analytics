--fct_high_trip_volume_low_fare_efficiency.sql
--Purpose: To find the daily hours where trip volume is high but the fare efficiency is below average.
--Grain: 1 row per unique combination of pickup_date, pickup_hour
--Source: mart.fct_hourly_demand, mart.fct_zone_efficiency
--Note:
-- -hourly avg fare per mile is aggregated from hourly demand table and daily avg fare per mile is aggregated from zone efficiency
-- - avg fare per mile threshold = 0.8(80%), high trips threshold = 0.8(80%)

CREATE OR REPLACE VIEW `nyc-taxi-485918.analytics.fct_high_trip_volume_low_fare_efficiency` AS
WITH base AS(
  SELECT
    hd.pickup_date,
    hd.pickup_hour,
    hd.total_trip,
    MAX(hd.total_trip) OVER(partition by hd.pickup_date) AS max_trip,
    SAFE_DIVIDE(hd.avg_fare,hd.avg_trip_distance) AS hourly_avg_fare_per_mile,
    AVG(ze.fare_per_miles) OVER(partition by hd.pickup_date) AS daily_avg_fare_per_mile
  FROM `nyc-taxi-485918.mart.fct_hourly_demand` AS hd
  JOIN `nyc-taxi-485918.mart.fct_zone_efficiency` AS ze ON hd.pickup_date=ze.pickup_date
)
SELECT
  *
FROM base
WHERE total_trip>=0.8*max_trip AND hourly_avg_fare_per_mile<0.8*daily_avg_fare_per_mile
GROUP BY pickup_date,pickup_hour,total_trip,max_trip,hourly_avg_fare_per_mile,daily_avg_fare_per_mile
