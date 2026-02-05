-- create_staging_deduplicated_view.sql
-- Purpose: To remove any duplicate rows present in the stg.events and create a view form it.
-- Grain: 1 row per unique combination of pickup_datetime, dropoff_datetime, pickup_location_id, dropoff_location_id, trip_distance, total_amount
-- Source: stg.events
-- Note: This staging view should be used to create the mart tables.

CREATE OR REPLACE VIEW `nyc-taxi-485918.stg.events_view_dedup` AS
SELECT
  *,
  ROW_NUMBER() OVER(
    PARTITION BY pickup_datetime, dropoff_datetime, pickup_location_id, dropoff_location_id, trip_distance, total_amount
  ) AS ranked
FROM `nyc-taxi-485918.stg.events`
QUALIFY ranked=1;
