## `Raw Layer`

### Overview

The **raw layer** contains the original NYC Taxi trip data ingested into BigQuery with **no business logic applied**.
This layer represents the **source of truth** and mirrors the upstream dataset as closely as possible.

The purpose of the raw layer is **data preservation**, not analysis.

---

### Characteristics

* One row per taxi trip
* Original schema and values retained
* Minimal transformations (type casting only if required)
* No aggregations, joins, or derived metrics

---

### Usage Guidelines

* Raw tables should **not** be queried directly for analytics or dashboards
* This layer exists to support:

  * Data validation
  * Reproducibility
  * Reprocessing into staging if logic changes

All analytical work begins from the **staging layer**, not raw.

---

### Summary

The raw layer acts as a stable ingestion point, ensuring the original data is always available and unchanged for downstream processing.
