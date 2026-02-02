# Analytics Layer

## Overview

The analytics layer contains **question-driven SQL analyses** built on top of the curated mart tables.
Each query answers a **specific business or operational question**, using pre-aggregated marts instead of raw trip data to ensure consistency and cost efficiency.

The goal of this layer is **insight and decision support**, not table creation.

---

## How to Read This Folder

SQL files are ordered to follow a **progressive analytical narrative**:

1. **When** does demand occur?
2. **Where** is demand concentrated?
3. **Is that demand efficient or wasteful?**
4. **How is revenue actually composed?**
5. **What decisions should be made?**

---

## Questions Answered

### Demand & Time Patterns

* What are the peak demand hours on weekdays vs weekends?
* Do peak demand hours also generate peak revenue?
* Which high-volume hours show low efficiency?

---

### Spatial & Zone Performance

* How concentrated is demand across pickup zones?
* Are there low-volume zones with high revenue per trip?
* How does zone performance differ across boroughs on weekdays vs weekends?

---

### Efficiency & Unit Economics

* Which zones generate the highest revenue per mile?
* Are high-trip zones also efficient in terms of revenue per minute?

---

### Distribution & Behavior

* How are trips distributed by distance across zones?
* Do certain zones show pricing or distance anomalies?

---

### Capstone / Decision-Oriented Analysis

* Can zones be segmented into demand-driven vs efficiency-driven groups?
* Where and when should additional taxis be deployed to maximize efficiency?

---

## Data Sources

All analytics queries read exclusively from the **mart layer**:

* `mart_hourly_demand`
* `mart_zone_daily_performance`
* `mart_zone_efficiency`
* `mart_zone_hourly_efficiency`
* `mart_trip_distribution`

Raw and staging tables are not used directly in this layer.

---

## Output & Usage

The results of these queries are used for:

* Exploratory analysis
* Looker Studio dashboards
* Feature generation for ML and clustering models

---

## Summary

The analytics layer translates curated data into **clear insights and actionable decisions**, moving from descriptive analysis to operational recommendations.
