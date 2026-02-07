-- 2_model_predict_trip.sql
-- Purpose: To create a regression model using random forest regressor.
-- Source: ML.mart_ml_trip_features
-- Training_data: Months- July, August, September
-- Note: There is no limit to how much past data can be use for prediction as long as its present in the data.

CREATE OR REPLACE MODEL `nyc-taxi-485918.ML.model_predict_trip`
OPTIONS(
  model_type='random_forest_regressor',
  input_label_cols=['total_trip'],
  ENABLE_GLOBAL_EXPLAIN=TRUE,
  subsample=0.8,
  max_tree_depth=6
) AS
SELECT
  pickup_hour,
  pickup_weekday,
  lag_1h,
  lag_24h,
  lag_7d,
  avg_24h,
  avg_7d
  total_trip
FROM `nyc-taxi-485918.ML.mart_ml_trip_features`
WHERE lag_1h IS NOT NULL AND lag_24h IS NOT NULL AND lag_7d IS NOT NULL AND pickup_date<'2021-10-01';
