# NYC Taxi Demand Forecasting & Allocation System

## Overview

This project builds an **end-to-end analytics and machine learning system** to analyze historical NYC taxi trips, **forecast hourly demand**, and **allocate taxis optimally across zones and hours**.

The system moves beyond descriptive dashboards into **predictive, decision-driven analytics**, combining:

* layered SQL transformations,
* time-aware demand forecasting (BigQuery ML),
* and rule-based allocation logic grounded in business efficiency.

---

## Objectives

* Understand **spatial and temporal demand patterns** in NYC taxi trips
* Identify **high-efficiency vs high-volume zones**
* Forecast **hourly taxi demand per zone**
* Allocate taxis **proactively** using predicted demand instead of reacting to past data

---

## Architecture Overview

```
raw → staging → marts → ml → analytics → dashboards
```

Each layer has a **single responsibility** and feeds cleanly into the next.

---

## Repository Structure

```
.
├── sql/
│   ├── raw/
│   ├── staging/
│   ├── marts/
│   ├── ml/
│   └── analytics/
│
├── DQ_check/
│   └── README.md
│
├── Dashboard/
│   └── README.md
│
└── README.md
```

---

## 🗃️ Data Layers (SQL)

### `raw/`

* Source ingestion
* Minimal schema alignment
* No transformations

### `staging/`

* Trip-level cleaning and enrichment
* Time features (date, hour, weekday)
* Zone and borough joins
* Deduplicated event views

### `marts/`

* Analytics-ready fact tables
* Clear grains (zone, zone × hour, zone × date)
* Stable historical metrics (demand, efficiency, duration)

### `ml/` (SQL)

* Feature generation from marts
* BigQuery ML model training & evaluation
* Batch demand prediction queries

### `analytics/`

* Decision-focused queries
* Taxi allocation logic
* Inputs for dashboards and reporting

---

## Machine Learning

* **Target:** Hourly taxi demand (`total_trips`)
* **Grain:** `pickup_zone_name × pickup_date × pickup_hour`
* **Approach:**

  * Time-based train / evaluation split
  * No data leakage
  * Batch inference for future dates
* **Output:** Predicted hourly trips per zone

ML is used to generate **forward-looking demand signals**, not to replace business logic.

Detailed documentation lives in `ml/README.md`.

---

## Taxi Allocation Logic

Allocation combines:

* **Historical structure**

  * Zone clusters (efficiency vs volume)
  * Priority hours (high demand + volatility)
* **Predicted demand**

  * Used as allocation weights

Key design principles:

* Clusters are built from **actual data**
* Predictions influence **how much**, not **what a zone is**
* Allocation is done **per hour**
* Explicit grain enforcement (`zone × hour`) prevents duplication

---

## Dashboards

Built in **Looker Studio** to visualize:

* Hourly demand patterns
* Zone efficiency
* Revenue per minute
* Allocation outcomes

Dashboards consume only **analytics-layer tables**, never raw data.

See `dashboards/README.md` for details.

---

## Design Principles

* Clear separation of concerns
* No analytics on raw data
* Time-aware modeling
* Explicit grain enforcement
* ML treated as a transformation layer
* Cost-aware querying (BigQuery Sandbox)

---

## End-to-End Flow (Daily Operation)

1. Historical data updates marts
2. ML model predicts **tomorrow’s hourly demand**
3. Allocation logic runs using predictions
4. Taxis are allocated by **zone × hour**
5. Dashboards reflect decisions

Changing the prediction date and rerunning allocation yields a **new operational plan**.

---

## Key Outcomes

* Built a **full analytics + ML pipeline**
* Forecasted demand instead of reacting to history
* Designed explainable, rule-driven allocation logic
* Avoided common pitfalls (data leakage, grain errors, duplication)
* Produced a **portfolio-ready, production-style project**

---

## Final Note

This project is intentionally designed to reflect **real-world analytics engineering practices**, not just isolated SQL queries or ML experiments.

It demonstrates how **data modeling, forecasting, and decision logic** work together in a cohesive system.
