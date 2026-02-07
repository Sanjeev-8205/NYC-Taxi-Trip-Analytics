-- 4_model_global_explain_features_and_attributions.sql
-- Purpose: To find the most effective features and their attributions.

CREATE OR REPLACE TABLE `nyc-taxi-485918.ML.model_global_explain_features_and_attributions` AS
SELECT
  *
FROM ML.GLOBAL_EXPLAIN(
  MODEL `nyc-taxi-485918.ML.model_predict_trip`
);
