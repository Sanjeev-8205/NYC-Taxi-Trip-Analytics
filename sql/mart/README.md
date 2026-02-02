# Mart Layer

## Overview

The mart layer contains **analytics-ready fact tables** derived from staging data.
These tables are optimized for **decision-making, dashboards, and advanced analytics**, and are designed to work efficiently under **BigQuery Sandbox constraints** (no partitioning).

---

## Design Principles

* Question-driven modeling
* Fact-first tables
* Denormalized dimensions for performance
* Pre-aggregation to reduce query cost

---

## Mart Tables

### `mart_zone_efficiency`

**Grain:** pickup_zone × pickup_date
**Focus:** Daily pricing and unit economics
**Key Metrics:**

* total_trips
* total_revenue
* total_trip_distance
* total_trip_duration_minutes
* avg_passenger_count

**Used for:** efficiency vs volume analysis, pricing power evaluation

---

### `mart_zone_hourly_efficiency`

**Grain:** pickup_zone × pickup_hour × day_of_week
**Focus:** Intra-day operational efficiency
**Key Metrics:**

* total_trip
* total_revenue
* total_distance
* trip_duration
* revenue_per_minute

**Used for:** congestion analysis, taxi supply optimization

---

### `mart_hourly_demand`

**Grain:** pickup_date × pickup_hour
**Focus:** Temporal demand patterns
**Key Metrics:**

* total_trip
* total_revenue
* avg_fare
* avg_trip_duration
* avg_trip_distance

**Used for:** peak-hour analysis, weekday vs weekend trends

---

### `mart_trip_distribution`

**Grain:** distance_bucket × pickup_zone
**Focus:** Trip behavior distribution
**Key Metrics:**

* trip_count
* avg_trip_distance
* avg_revenue
* avg_fare

**Used for:** revenue composition, anomaly detection

---

### `mart_zone_daily_performance`

**Grain:** pickup_zone × pickup_date
**Focus:** Daily zone and borough performance
**Key Metrics:**

* total_trips
* total_revenue
* avg_fare
* avg_distance
* avg_trip_duration
* trips_per_hour

**Used for:** zone ranking, borough comparison, demand concentration

---

## Fact & Dimension Strategy

All tables are modeled as **fact tables**.
Time, zone, and borough attributes are embedded as **denormalized dimensions** to simplify analytics and improve performance.

---

## Downstream Usage

Mart tables act as the **single source of truth** for:

* Analytics SQL
* Looker Studio dashboards
* ML and clustering features

---

## Summary

This mart layer converts trip-level data into **decision-ready datasets** spanning demand, efficiency, spatial performance, and operations.
