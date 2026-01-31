--create_staging_table.sql
--Purpose: To create a transformed, cleaned and consistent form of the raw.raw_events.
--Source: raw.raw_events

CREATE OR REPLACE TABLE `nyc-taxi-485918.stg.events` AS
SELECT
  pickup_datetime,
  EXTRACT(DATE FROM pickup_datetime) AS pickup_date,
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_weekday,
  pickup_location_id,
  pickup_zone_name,
  pickup_borough,
  pickup_geom,
  dropoff_datetime,
  EXTRACT(DATE FROM dropoff_datetime) AS dropoff_date,
  EXTRACT(HOUR FROM dropoff_datetime) AS dropoff_hour,
  EXTRACT(DAYOFWEEK FROM dropoff_datetime) AS dropoff_weekday,
  dropoff_location_id,
  dropoff_zone_name,
  dropoff_borough,
  dropoff_geom,
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) AS trip_duration_minutes,
  rate_code AS rate_code,
  passenger_count AS passenger_count,
  trip_distance AS trip_distance,
  fare_amount AS fare_amount,
  extra,
  mta_tax,
  trip_type,
  tolls_amount,
  payment_type,
  total_amount
FROM `nyc-taxi-485918.raw.events_raw`
WHERE pickup_datetime>='2021-07-01'
ORDER BY pickup_date
