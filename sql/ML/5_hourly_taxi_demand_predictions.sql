-- 5_hourly_taxi_demand_predictions.sql
-- Purpose: To predict the taxi demand on October 1,2021 and then store them in a table.
-- Note:
-- -This is a very important table as this stores the predictions odf the model.
-- -These predictions are used in taxi allocation query to allocate the taxis for the specific date.

CREATE OR REPLACE TABLE `nyc-taxi-485918.ML.hourly_taxi_demand_predictions` AS
SELECT
  pickup_zone_name,
  predicted_total_trip AS predicted_trips,
  pickup_date AS prediction_date,
  MOD(pickup_hour+1, 24) AS predicted_hour,
FROM ML.PREDICT(
  MODEL `nyc-taxi-485918.ML.model_predict_trip`,
  (
  SELECT *
  FROM `nyc-taxi-485918.ML.mart_ml_trip_features`
  WHERE pickup_date='2021-10-01'
  )
)
