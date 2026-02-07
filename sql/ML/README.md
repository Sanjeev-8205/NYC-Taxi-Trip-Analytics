# Machine Learning & Forecasting

This folder contains all **machine learning assets** used to forecast **hourly taxi demand** and support **forward-looking taxi allocation** decisions.

The ML layer is intentionally isolated from analytics to keep **experimentation, training, and inference** separate from business-facing outputs.

---

## Goal

Predict **hourly taxi demand (`total_trips`)** at the
**pickup_zone_name × pickup_date × pickup_hour** level.

These predictions are later used as **demand weights** in the taxi allocation logic.

### Feature Engineering

* Grain: `zone × date × hour`
* Historical trip counts
* Lag features and rolling averages
* Temporal attributes (hour, weekday)

Designed specifically for **time-aware forecasting**.

---

### Model Training

* Trained on historical hourly demand
* Time-based split used for evaluation
  (earlier months → training, later months → validation)
* No future data leakage

---

### Model Evaluation

Evaluation performed on **unseen future periods** using:

* MAE / Median AE
* R² score
* Explained variance

Ensures the model generalizes beyond the training window.

---

### Predictions

* Generates **predicted hourly trips per zone**
* Predictions can be run:

  * for a specific date (e.g., next day)
  * or in batch mode for multiple dates

Predictions are treated as **data outputs**, not business logic.

---

## Downstream Usage

* **Historical data** defines:

  * zone clusters
  * priority hours
* **Predicted demand** defines:

  * allocation weights

Predictions are consumed by the **analytics layer** for taxi allocation and dashboards.

---

## Design Principles

* Train on past data, predict future demand
* No data leakage
* Explicit time awareness
* Stable historical structure + dynamic predictions
* ML supports decisions; it does not replace business rules

---

## Pipeline Position

```
raw / stg
   ↓
mart
   ↓
ml   (features → model → predictions)
   ↓
analytics   (allocation & dashboards)
```

---

## Summary

The `ml/` folder implements a complete **forecasting pipeline**:
feature engineering → model training → evaluation → prediction.

It enables **proactive taxi allocation**, making the system predictive rather than reactive.
