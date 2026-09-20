# Restaurant Sales & Order Analysis

**MySQL 8.0+ | Sales Analysis | Menu Performance | Order Behavior**

A portfolio case study using restaurant order data to evaluate sales performance, menu contribution, order patterns, time-of-day demand, and data-quality limitations.

## Business Context

Restaurant transaction data can help answer practical questions about what sells, when orders occur, which categories contribute the most revenue, and where data-quality issues may affect reporting.

This project uses two related tables—menu items and order-detail transactions—to build a reproducible SQL analysis. The emphasis is on reliable metric definitions and evidence-based business interpretation rather than producing a large number of queries.

## Objective

The analysis aims to understand:

- matched menu-price revenue and order-level sales performance
- menu-item and category contribution
- order volume and order-size patterns
- hourly and day-of-week demand
- recurring item pairings
- revenue concentration across menu items
- limitations created by missing item references

## Business Questions

1. What is the total matched menu-price revenue?
2. What is the average order value for orders with at least one matched menu item?
3. Which menu items generate the most revenue?
4. Which menu items have the highest order volume?
5. Which categories contribute the most matched revenue?
6. How does matched revenue change over time?
7. Which hours and days have the highest order activity?
8. What is the observed order-size distribution?
9. Which item pairs commonly occur in the same order?
10. How does observed item demand vary across price tiers?

## Dataset

The repository contains the original CSV files used for the analysis.

| Table | Rows | Purpose |
|---|---:|---|
| `menu_items` | 32 | Menu item, category, and price reference |
| `order_details` | 12,234 | Order-detail transactions |
| Distinct orders | 5,370 | Unique source orders |

**Categories:** 4  
**Analysis period:** January 1, 2023 – March 31, 2023  
**Menu price range:** $5.00 – $19.95

### `menu_items`

- `menu_item_id`
- `item_name`
- `category`
- `price`

### `order_details`

- `order_details_id`
- `order_id`
- `order_date`
- `order_time`
- `item_id`

`order_details.item_id` references `menu_items.menu_item_id` when a valid menu item is available.

## Data Quality

The raw source contains **137 order-detail rows with a literal `NULL` value in `item_id`**.

Those rows affect **137 of 5,370 orders (2.55%)**. Of those, **27 orders (0.50%) have no matched menu item at all**.

The raw CSV files are preserved. Missing-item rows are not deleted or assigned an invented price.

For price-based analysis:

- **12,097** order-detail rows have a valid menu-item match.
- **5,343** source orders have at least one matched menu item.
- The **$159,217.90** revenue figure is therefore **matched menu-price revenue**.
- AOV is calculated using those **5,343 valued orders**, not the 5,370 source orders.

Additional quality checks cover duplicate IDs, full-record duplicates, required fields, unexpected categories, date/time validity, price validity, and menu-item coverage.

## Analytical Approach

```
Raw CSV Data
    ↓
Data Profiling
    ↓
Data Quality Validation
    ↓
Matched / Reliable Analytical Records
    ↓
Revenue & Menu Analysis
    ↓
Order Behavior Analysis
    ↓
Advanced SQL
    ↓
Findings & Testable Recommendations
```

## Core Validated Metrics

| Metric | Result |
|---|---:|
| Source orders | **5,370** |
| Valued orders | **5,343** |
| Matched order-detail rows | **12,097** |
| Matched menu-price revenue | **$159,217.90** |
| Matched-order AOV | **$29.80** |
| Matched items per valued order | **2.26** |

### Revenue by Category

| Category | Revenue | Revenue Share |
|---|---:|---:|
| Italian | $49,462.70 | 31.07% |
| Asian | $46,720.65 | 29.34% |
| Mexican | $34,796.80 | 21.85% |
| American | $28,237.75 | 17.74% |

### Highest-Revenue Menu Items

| Item | Items Sold | Revenue |
|---|---:|---:|
| Korean Beef Bowl | 588 | $10,554.60 |
| Spaghetti & Meatballs | 470 | $8,436.50 |
| Tofu Pad Thai | 562 | $8,149.00 |
| Cheeseburger | 583 | $8,132.85 |
| Hamburger | 622 | $8,054.90 |

### Highest-Volume Menu Items

| Item | Items Sold |
|---|---:|
| Hamburger | 622 |
| Edamame | 620 |
| Korean Beef Bowl | 588 |
| Cheeseburger | 583 |
| French Fries | 571 |

### Order Timing

**12:00 PM** is the busiest hour with **647 source orders (12.05%)**.

The **11 AM–2 PM** lunch window contains **1,956 source orders (36.42%)**.

### Order Size

| Order size | Share of source orders |
|---|---:|
| 1 item | 38.23% |
| 2–3 items | 44.58% |
| 4–6 items | 14.77% |
| 7–10 items | 1.42% |
| 11+ items | 1.01% |

## Static Visual Summary

<img src="docs/revenue_by_category.svg" alt="Revenue by category" width="760">

<img src="docs/monthly_revenue.svg" alt="Monthly matched revenue" width="760">

<img src="docs/orders_by_hour.svg" alt="Source orders by hour" width="760">

These visuals are static supporting outputs, not a Power BI dashboard.

A Power BI implementation plan is documented in `docs/powerbi_dashboard_spec.md`.

## SQL Analysis

### 1. Setup
Database creation, table definitions, indexes, and reproducible MySQL CSV-load examples.

### 2. Data Quality
Row counts, duplicate detection, missing-item impact, referential integrity, categories, dates, times, and prices.

### 3. Revenue Analysis
Matched revenue, AOV, category contribution, menu-item revenue, daily/monthly trends, price tiers, and week-over-week movement.

### 4. Menu Performance
Item volume, category performance, item ranking, descriptive price-tier analysis, performance matrix, and revenue contribution.

### 5. Order Behavior
Hourly demand, service windows, order-size distribution, matched AOV by hour/day, category mix, and basket pairings.

### 6. Advanced SQL
Category ranking, cumulative contribution, month-over-month movement, seven-day moving average, ABC/Pareto classification, anomaly screening, revenue concentration, and category mix over time.

The repository currently contains **40 SELECT-based analysis/data-quality queries**, excluding setup/load statements.

## Reproducibility

### Requirements

- MySQL 8.0+
- MySQL client with `LOCAL INFILE` enabled for CSV loading

### 1. Create the database and tables

From the repository root:

```bash
mysql -u YOUR_USERNAME -p < sql/01_setup/create_tables.sql
```

The setup script creates and selects the `restaurant_orders` database.

### 2. Load the CSV data

Run the commented `LOAD DATA LOCAL INFILE` examples in `sql/01_setup/create_tables.sql`.

Load `menu_items.csv` first.

For `order_details.csv`, the source text `NULL` values are converted to SQL NULL with:

```sql
SET item_id = NULLIF(@item_id, 'NULL');
```

### 3. Run the analysis

Run:

```
sql/02_analysis/data_quality.sql
sql/02_analysis/revenue_analysis.sql
sql/02_analysis/menu_performance.sql
sql/02_analysis/order_behavior.sql
sql/03_advanced/advanced_analysis.sql
```

### 4. Review the written analysis

- `analysis/key_findings.md`
- `analysis/recommendations.md`

## SQL Techniques

The current SQL demonstrates:

- JOINs
- aggregation and GROUP BY
- CASE
- subqueries
- CTEs
- window functions
- RANK
- LAG
- cumulative calculations
- rolling averages
- percentage-of-total calculations
- MySQL date/time functions
- basket analysis
- ABC/Pareto analysis
- standard-deviation screening

## Recommendations

Recommendations are framed as **testable business actions**, not guaranteed outcomes. The dataset does not contain costs, margins, customer IDs, staffing data, wait times, discounts, refunds, or experiment results, so profitability, customer retention, staffing impact, and price elasticity require additional data or controlled testing.

See `analysis/recommendations.md` for the detailed recommendation-to-validation framework.

## Limitations

- The analysis covers a three-month observation period.
- 137 source rows have missing `item_id` values.
- 27 source orders have no matched menu item, so their item-level revenue cannot be established.
- Revenue is menu-price revenue, not profit.
- There is no cost, margin, tax, discount, refund, or labor data.
- There is no customer identifier, so the project cannot support customer retention or lifetime-value analysis.
- There is no staffing, queue, or ticket-time data, so operational impact cannot be quantified.
- Missing item references should be resolved before using this dataset for complete profitability or menu-level performance decisions.

## Project Structure

```
restaurant-sales-order-analysis/
├── data/
│   └── raw/
│       ├── menu_items.csv
│       ├── order_details.csv
│       └── restaurant_db_data_dictionary.csv
├── sql/
│   ├── 01_setup/
│   │   └── create_tables.sql
│   ├── 02_analysis/
│   │   ├── data_quality.sql
│   │   ├── menu_performance.sql
│   │   ├── order_behavior.sql
│   │   └── revenue_analysis.sql
│   └── 03_advanced/
│       └── advanced_analysis.sql
├── analysis/
│   ├── key_findings.md
│   └── recommendations.md
├── docs/
│   ├── SQL_TECHNIQUES.md
│   ├── powerbi_dashboard_spec.md
│   ├── orders_by_hour.svg
│   ├── monthly_revenue.svg
│   └── revenue_by_category.svg
├── .gitignore
├── LICENSE
└── README.md
```

## Author

**Golam Shakir**

## License

MIT License
