## Staging Layer

### Overview

The **staging layer** contains cleaned, standardized, and enriched trip-level data derived from the raw layer.
Each table represents a **single business event (one taxi trip)** and serves as the foundation for all downstream marts.

This layer prepares the data for analysis **without performing aggregation**.

---

### Key Transformations

* Data type normalization
* Null handling and basic data quality checks
* Time-based derivations (date, hour, weekday)
* Trip-level calculations (duration, basic ratios)
* Zone and borough enrichment

---

### Characteristics

* One row per completed trip
* No aggregation or summarization
* Columns are analytics-ready but still granular
* Designed for reuse across multiple marts

---

### Usage Guidelines

* Staging tables should **not** be used directly for dashboards
* They are intended to:

  * Feed multiple mart tables
  * Centralize cleansing logic
  * Avoid duplication of transformations

All aggregations and business metrics are handled in the **mart layer**.

---

### Summary

The staging layer bridges raw ingestion and analytics modeling by transforming raw events into **clean, consistent, and reusable trip-level data**.
