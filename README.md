# Restaurant Sales & Order Analysis

**MySQL 8.0+ | SQL Analytics | Data Quality | Business Insights**

## Overview

This project analyzes restaurant order data to understand revenue performance, menu-item demand, category contribution, order patterns, and time-based ordering activity.

The analysis follows a structured workflow: **data profiling → data-quality validation → revenue analysis → menu performance → order behavior → advanced SQL analysis → business findings and recommendations**.

The project is designed to demonstrate how transactional data can be transformed into reliable, business-oriented insights using SQL while clearly documenting data limitations and analytical assumptions.

---

## Business Objectives

The analysis focuses on the following business areas:

* Revenue and average order value
* Menu-item and category performance
* Order volume and order-size patterns
* Peak ordering periods
* Item-level revenue contribution
* Basket/item-pair relationships
* Revenue concentration and menu mix
* Data-quality risks that may affect analysis

---

## Key Business Questions

### Revenue Performance

* What is the total matched menu-price revenue?
* What is the average order value?
* How does revenue change over time?
* Which menu categories contribute the most revenue?
* Which menu items generate the most revenue?

### Menu Performance

* Which items have the highest order volume?
* Which items contribute the most revenue?
* How concentrated is revenue across menu items?
* How does observed demand vary across price tiers?
* Which items have relatively lower volume or revenue and warrant further review?

### Order Behavior

* What are the busiest ordering hours?
* Which days have the highest order activity?
* What is the distribution of items per order?
* Which menu-item pairs occur most frequently within the same order?

### Data Quality

* Are there duplicate order-detail identifiers?
* Are there missing values?
* Are menu-item references valid?
* Are prices and dates within expected ranges?
* How do missing item references affect price-based revenue analysis?

---

## Dataset

The repository contains two primary tables and a data dictionary.

### `menu_items`

| Column         | Description                 |
| -------------- | --------------------------- |
| `menu_item_id` | Unique menu-item identifier |
| `item_name`    | Menu item name              |
| `category`     | Menu category/cuisine       |
| `price`        | Menu price in USD           |

### `order_details`

| Column             | Description                                     |
| ------------------ | ----------------------------------------------- |
| `order_details_id` | Unique identifier for an order line             |
| `order_id`         | Identifier grouping items within the same order |
| `order_date`       | Order date                                      |
| `order_time`       | Order time                                      |
| `item_id`          | Reference to `menu_items.menu_item_id`          |

### Dataset Snapshot

| Metric                      |                      Value |
| --------------------------- | -------------------------: |
| Analysis period             | January 1 – March 31, 2023 |
| Order-detail rows           |                     12,234 |
| Distinct orders             |                      5,370 |
| Known menu items            |                         32 |
| Menu categories             |                          4 |
| Rows with missing `item_id` |                        137 |

The dataset does not contain a customer identifier, cost data, margin data, staffing information, wait times, discounts, refunds, or tax information.

---

## Data Model

The main relationship is:

```text
menu_items.menu_item_id
        │
        │ 1-to-many
        ▼
order_details.item_id
```

The `item_id` field is nullable because the source data contains 137 order-detail rows without a usable menu-item reference.

---

## Data Quality Approach

Data quality is treated as part of the analysis rather than as a separate cleanup step.

The validation process includes:

* Row-count validation
* Duplicate identifier checks
* Missing-value checks
* Referential-integrity checks
* Menu-item uniqueness checks
* Price validation
* Date-range validation
* Coverage checks for known menu items
* Validation of the analytical revenue base

### Missing `item_id` Values

The source data contains **137 order-detail rows with a literal `NULL` item ID**.

These records are:

1. Preserved in the raw dataset
2. Not assigned an estimated menu item
3. Not assigned an estimated price
4. Excluded from price-based revenue calculations because a reliable menu price cannot be established

This represents approximately **1.12% of all source order-detail rows**.

This treatment keeps the raw data intact while preventing unsupported revenue assumptions.

---

## Revenue Definition

Revenue analysis is based on **matched menu-price values**.

For each order-detail row with a valid menu-item match:

```text
Revenue = Menu Item Price
```

The dataset does not contain a separate quantity field; each order-detail row represents an item recorded within an order.

Rows with missing `item_id` values are excluded from price-based revenue calculations because their menu price cannot be reliably identified.

Therefore, reported revenue should be interpreted as:

> **Matched menu-price revenue, not profit or net sales.**

The dataset does not provide:

* product cost
* gross margin
* discounts
* taxes
* refunds
* labor cost
* operating expenses

---

## Analytical Workflow

```text
Raw CSV Data
      │
      ▼
Data Profiling
      │
      ▼
Data Quality Validation
      │
      ▼
Reliable Analytical Base
      │
      ├── Revenue Analysis
      ├── Menu Performance
      ├── Order Behavior
      └── Advanced SQL Analysis
      │
      ▼
Key Findings
      │
      ▼
Evidence-Based Recommendations
```

---

## Key Findings

### Revenue Performance

* Matched menu-price revenue totaled **$159,217.90** across **5,370 orders**.
* Average order value was approximately **$29.65**.
* Italian generated the largest share of matched revenue at **31.07%**.
* Asian contributed **29.34%** of matched revenue.

### Menu Performance

The highest-revenue menu items were:

| Menu Item             | Items Sold |    Revenue |
| --------------------- | ---------: | ---------: |
| Korean Beef Bowl      |        588 | $10,554.60 |
| Spaghetti & Meatballs |        470 |  $8,436.50 |
| Tofu Pad Thai         |        562 |  $8,149.00 |
| Cheeseburger          |        583 |  $8,132.85 |
| Hamburger             |        622 |  $8,054.90 |

Hamburger had the highest observed item volume at **622 units**, while Korean Beef Bowl generated the highest revenue at **$10,554.60**.

This demonstrates why menu evaluation should consider both **volume and revenue contribution** rather than relying on a single metric.

### Order Timing

* **12:00 PM** was the busiest hour with **644 orders**, representing approximately **11.99% of all orders**.
* The **11 AM–2 PM** lunch period represented approximately **36.2% of orders** based on matched order activity.

This provides a basis for reviewing midday preparation, staffing, and service capacity, but the dataset does not contain the operational metrics required to quantify those effects.

### Order Size

The largest observed order-size group was **2–3 items per order**, representing approximately **44.58% of matched orders**.

This pattern provides a useful basis for testing bundle and cross-sell ideas, but historical co-occurrence alone does not demonstrate incremental revenue.

### Basket Pairings

Frequently observed item pairs included:

| Item Pair                       | Orders |
| ------------------------------- | -----: |
| Hamburger + Edamame             |     78 |
| Cheeseburger + Edamame          |     75 |
| Hamburger + Cheeseburger        |     72 |
| Korean Beef Bowl + Edamame      |     68 |
| French Fries + Korean Beef Bowl |     66 |

These relationships can support menu merchandising or bundle experiments.

### Monthly Revenue

| Month    |    Revenue | Change vs. Prior Month |
| -------- | ---------: | ---------------------: |
| January  | $53,816.95 |                      — |
| February | $50,790.35 |                 -5.62% |
| March    | $54,610.60 |                 +7.52% |

Revenue declined in February and recovered in March. The three-month observation period is not sufficient to establish a sustained long-term growth trend.

---

## Business Recommendations

The analysis supports several areas for further business investigation.

### 1. Evaluate Menu Performance Using Both Volume and Revenue

Volume leaders and revenue leaders are not always the same. Menu reviews should therefore consider both metrics before making product decisions.

### 2. Investigate Missing Item References

The 137 records with missing `item_id` values should be traced back to the original source system or transaction extract to improve item-level analytical completeness.

### 3. Test Bundles Around Observed Item Pairings

Frequently co-occurring items can be used to design small bundle or merchandising experiments.

Future testing should monitor:

* Average order value
* Units per order
* Bundle attachment rate
* Gross margin
* Cannibalization of standalone items

### 4. Review Midday Capacity

The concentration of orders around lunch provides a reason to review preparation, staffing, throughput, and peak-period service performance.

### 5. Monitor Category Mix

Italian and Asian categories are the largest revenue contributors and should be monitored regularly alongside volume, availability, and margin.

### 6. Treat Price Findings as Descriptive

The current dataset can describe demand across price tiers, but it cannot establish price elasticity or causal effects. Any pricing change should be evaluated through controlled testing using revenue and margin outcomes.

---

## SQL Techniques

The project uses **MySQL 8.0+** and demonstrates:

### Core SQL

* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `CASE`
* Aggregate functions
* `JOIN`
* Subqueries

### Analytical SQL

* Common Table Expressions (CTEs)
* Window functions
* `RANK()`
* `ROW_NUMBER()`
* `NTILE()`
* `LAG()`
* Cumulative sums
* Rolling averages
* Percentage-of-total calculations

### Time-Based Analysis

* `HOUR()`
* `DAYNAME()`
* `DAYOFWEEK()`
* `DATE_FORMAT()`
* `WEEKDAY()`
* Date-based aggregation

### Business Analysis

* Revenue contribution
* Average Order Value
* Order-size distribution
* Category mix
* Menu-item ranking
* Basket/item-pair analysis
* ABC/Pareto classification
* Revenue concentration
* Descriptive anomaly screening

### Data Quality

* Duplicate detection
* NULL checks
* Referential-integrity validation
* Date-range checks
* Price validation

Advanced SQL is used where it improves the analysis rather than simply increasing query complexity.

---

## Project Structure

```text
restaurant-sales-order-analysis/
│
├── analysis/
│   ├── key_findings.md
│   └── recommendations.md
│
├── data/
│   └── raw/
│       ├── menu_items.csv
│       ├── order_details.csv
│       └── restaurant_db_data_dictionary.csv
│
├── docs/
│   └── SQL_TECHNIQUES.md
│
├── sql/
│   ├── 01_setup/
│   │   └── create_tables.sql
│   │
│   ├── 02_analysis/
│   │   ├── data_quality.sql
│   │   ├── revenue_analysis.sql
│   │   ├── menu_performance.sql
│   │   └── order_behavior.sql
│   │
│   └── 03_advanced/
│       └── advanced_analysis.sql
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Getting Started

### Prerequisites

* MySQL 8.0+
* MySQL Workbench or another MySQL client
* Access to the repository CSV files

### 1. Create or select a MySQL database

Create a MySQL database and select it before running the setup script.

### 2. Create the analytical tables

Run:

```text
sql/01_setup/create_tables.sql
```

The setup script defines the analytical schema and includes reproducible CSV loading examples.

### 3. Load the raw CSV files

Use the `LOAD DATA LOCAL INFILE` examples provided in `create_tables.sql`.

The `order_details.csv` import converts the source text value:

```text
NULL
```

into SQL `NULL` using:

```sql
NULLIF(@item_id, 'NULL')
```

Depending on your MySQL configuration, `LOCAL INFILE` may need to be enabled.

### 4. Run data-quality validation

Execute:

```text
sql/02_analysis/data_quality.sql
```

Review the data-quality output before interpreting price-based revenue.

### 5. Run the analysis

Execute the analysis files in this order:

```text
sql/02_analysis/revenue_analysis.sql
sql/02_analysis/menu_performance.sql
sql/02_analysis/order_behavior.sql
sql/03_advanced/advanced_analysis.sql
```

### 6. Review the analytical outputs

See:

* [`analysis/key_findings.md`](analysis/key_findings.md)
* [`analysis/recommendations.md`](analysis/recommendations.md)
* [`docs/SQL_TECHNIQUES.md`](docs/SQL_TECHNIQUES.md)

---

## Limitations

This project supports descriptive restaurant analytics, but the dataset is not sufficient for:

* Profitability analysis
* Gross-margin analysis
* Customer retention analysis
* Customer lifetime value
* Customer segmentation
* Staffing ROI
* Wait-time analysis
* Price elasticity estimation
* Causal impact measurement

The analysis is also limited to a **three-month observation period**.

The 137 source rows with missing `item_id` values introduce an additional limitation for complete item-level revenue analysis.

---

## Analytical Interpretation

The results should be interpreted as **descriptive evidence from the available transaction data**, not as proof of causation.

For example:

* Frequent item pairings indicate co-occurrence, not causality.
* Higher or lower item volume does not by itself establish pricing effectiveness.
* Revenue concentration does not automatically imply that a product should be expanded or removed.
* Operational recommendations require operational data to quantify their impact.

Business recommendations therefore should be treated as **testable actions and hypotheses** rather than guaranteed outcomes.

---

## Documentation

Additional project documentation is available in:

* [`analysis/key_findings.md`](analysis/key_findings.md) — validated analytical findings
* [`analysis/recommendations.md`](analysis/recommendations.md) — evidence-based recommendations and validation ideas
* [`docs/SQL_TECHNIQUES.md`](docs/SQL_TECHNIQUES.md) — SQL techniques used in the project
* [`data/raw/restaurant_db_data_dictionary.csv`](data/raw/restaurant_db_data_dictionary.csv) — dataset field definitions

---

## Tools & Technologies

| Tool                | Purpose                                    |
| ------------------- | ------------------------------------------ |
| **MySQL 8.0+**      | Database and SQL analysis                  |
| **MySQL Workbench** | SQL development and execution              |
| **CSV**             | Raw dataset format                         |
| **GitHub**          | Version control and portfolio presentation |
| **Markdown**        | Analytical documentation                   |

---

## Project Objective

The primary objective of this project is to demonstrate a professional analytical workflow:

> **Validate the data → build reliable metrics → analyze business performance → identify patterns → communicate evidence-based findings.**

The emphasis is on **analytical correctness, transparent assumptions, reproducibility, and business relevance**.

---

## Author

**Golam Shakir**

Data Analyst Portfolio Project

---

## License

The original SQL queries, documentation, and project materials in this repository are licensed under the MIT License.

The included restaurant dataset is used for analytical/educational purposes and may be subject to separate rights or licensing terms from its original source. The MIT License does not grant additional rights to third-party dataset content.
