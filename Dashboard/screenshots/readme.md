# Dashboards

## Overview

This folder contains **Looker Studio dashboards** built on top of the curated analytics marts.
The dashboards are designed to translate analytical results into **clear, decision-oriented visuals** for business, strategy, and operations use cases.

Each dashboard corresponds to a distinct analytical goal and audience, rather than combining everything into a single overloaded view.

---

## Dashboard Structure

### Demand and Revenue Overview

**Purpose:**
Provide a high-level view of **when demand occurs and how it translates into revenue**.

**Key Focus Areas:**

* Overall trip volume and revenue context
* Weekday vs weekend demand patterns
* Hourly demand compared with hourly revenue
* Spatial distribution of trips across pickup zones

**Primary Questions Answered:**

* When does taxi demand peak?
* Does peak demand align with peak revenue?
* Where is demand geographically concentrated?

---

### Zone Performance and Efficiency

**Purpose:**
Evaluate **zone-level performance and pricing efficiency**, separating volume from value.

**Key Focus Areas:**

* Revenue per mile by pickup zone
* Volume vs efficiency trade-offs across boroughs
* Borough-level performance comparison
* Detailed zone efficiency rankings

**Primary Questions Answered:**

* Which zones generate the most value per mile?
* Are high-volume zones also high-efficiency zones?
* How does efficiency differ across boroughs?

---

### Operational Efficiency and Supply Optimization

**Purpose:**
Support **operational decision-making** by identifying high-value and low-efficiency zone–hour combinations.

**Key Focus Areas:**

* Zone × hour revenue-per-minute heatmap
* Identification of inefficient peak hours
* Prioritized zone-hour combinations for taxi allocation

**Primary Questions Answered:**

* When does congestion reduce efficiency?
* Which zone-hour windows generate the highest value?
* Where should additional taxi supply be allocated?

---

## Data Sources

All dashboards are built exclusively from the **mart layer**, including:

* `mart_hourly_demand`
* `mart_zone_daily_performance`
* `mart_zone_efficiency`
* `mart_zone_hourly_efficiency`

Raw and staging tables are not used directly in dashboards.

---

## Design Philosophy

* One dashboard per analytical objective
* Clear separation between **overview**, **analysis**, and **action**
* Minimal visual clutter, emphasis on readability
* Visuals chosen to support decisions, not decoration

---

## Summary

The dashboards provide a **complete analytical narrative** — moving from demand visibility, to zone-level efficiency, and finally to **actionable operational insights**.
They serve as the primary interface for communicating insights derived from the analytics pipeline.
