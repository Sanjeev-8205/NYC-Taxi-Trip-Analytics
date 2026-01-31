--create_raw_view.sql
--Purpose: Create the raw.events view.
--Source: `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2021`
--Note: The raw.events_raw view references the bigquery public dataset table mentioned in the source.

CREATE OR REPLACE VIEW `nyc-taxi-485918.raw.events_raw` AS
SELECT
  gt2021.*,
  tzg.zone_name AS pickup_zone_name,
  tzg.borough AS pickup_borough,
  tzg.zone_geom AS pickup_geom,
  tzg_1.zone_name AS dropoff_zone_name,
  tzg_1.borough AS dropoff_borough,
  tzg_1.zone_geom AS dropoff_geom
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2021` AS gt2021
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` AS tzg ON gt2021.pickup_location_id=tzg.zone_id
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` AS tzg_1 ON gt2021.dropoff_location_id=tzg_1.zone_id; 
