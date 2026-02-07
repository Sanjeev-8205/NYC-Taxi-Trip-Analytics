# SQL Layer

## Overview

The `sql/` folder contains **all transformation and analysis logic** used in this project.
SQL is organized by data layer to keep responsibilities clear and to make the pipeline easy to understand, debug, and extend.

Each subfolder represents a **distinct stage in the analytics workflow**.

---

## Folder Structure

```
sql/
├── raw/
├── staging/
├── marts/
├── ml/
└── analytics/
```

---

## `sql/raw/`

**Purpose:** Data ingestion and light normalization

Contains SQL used to:

* Load source data into BigQuery
* Apply minimal schema alignment if required

No business logic or transformations are applied here.

---

## `sql/staging/`

**Purpose:** Trip-level cleaning and enrichment

Contains SQL that:

* Cleans and standardizes raw trip data
* Derives time attributes (date, hour, weekday)
* Computes trip-level metrics (duration, distance)
* Enriches records with zone and borough information

Each query outputs **one row per taxi trip**.

---

## `sql/marts/`

**Purpose:** Analytics-ready fact tables

Contains SQL that:

* Aggregates staging data into decision-ready marts
* Defines clear table grains and business metrics
* Optimizes for performance and cost efficiency

These queries form the **single source of truth** for analytics and dashboards.

---

## sql/ml/

**Purpose:** Feature engineering and model orchestration

Contains SQL used to:

* Generate ML-ready feature tables from mart data
* Train and evaluate BigQuery ML models
* Run batch predictions for hourly demand forecasting
* These queries consume mart tables and produce outputs that are later used by the analytics layer for taxi allocation.

Detailed ML logic and design decisions are documented separately in the project’s ml/ folder.

---

## `sql/analytics/`

**Purpose:** Question-driven analysis and insights

Contains SQL that:

* Answers specific analytical and operational questions
* Reads only from mart tables (not raw or staging)
* Supports dashboards and downstream modeling

Files are ordered to reflect a **progressive analytical narrative**.

---

## Design Principles

* Clear separation of concerns by data layer
* No analytics directly on raw data
* Reusable, composable SQL
* Cost-aware querying under BigQuery Sandbox constraints
* ML workflows consume curated marts and do not bypass the analytics pipeline

---

## Usage Notes

* Each SQL file is designed to be runnable independently
* Table creation logic is isolated from analytical queries
* Changes in logic should propagate **raw → staging → marts → ml → analytics**

---

## Summary

The `sql/` folder serves as the **backbone of the project**, capturing all transformations and analyses in a clear, layered, and maintainable structure.
