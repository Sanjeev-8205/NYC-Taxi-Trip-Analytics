-- 3_model_evaluation.sql
-- Purpose: To evaluate the model performance based on the error metrics.

CREATE OR REPLACE TABLE `nyc-taxi-485918.ML.model_evaluation` AS
SELECT *
FROM ML.EVALUATE(
  MODEL `nyc-taxi-485918.ML.model_predict_trip`,
  (
    SELECT
      pickup_hour,
      pickup_weekday,
      lag_1h,
      lag_24h,
      lag_7d,
      avg_24h,
      avg_7d,
      total_trip
    FROM `nyc-taxi-485918.ML.mart_ml_trip_features`
    WHERE pickup_date>='2021-10-01'
  )
);
