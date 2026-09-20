# Restaurant Sales & Order Analysis

A recruiter-ready **MySQL 8.0 data analytics portfolio project** analyzing restaurant transactions from January 1 through March 31, 2023.

The project combines data-quality validation, SQL-based exploratory analysis, business-focused performance analysis, and concise documentation. The goal is to show a practical analytics workflow: **validate the data → define reliable metrics → analyze patterns → communicate evidence-based findings**.

## Business Context

The dataset contains restaurant menu items and order-detail transactions. The analysis focuses on revenue, menu performance, order behavior, time-of-day demand, basket combinations, and revenue concentration.

Revenue calculations use order-detail rows that can be matched to a known menu item price. The raw CSV is preserved, including 137 rows whose `item_id` value is the literal `NULL` string and therefore cannot be assigned a menu price without additional information.

## Key Business Questions

1. How much revenue and order volume does the restaurant generate?
2. Which menu categories and items contribute the most revenue?
3. Which items have the highest and lowest order volume?
4. How does demand vary by hour and day of week?
5. What does order-size behavior look like?
6. Which menu items are frequently ordered together?
7. How concentrated is revenue across the menu?
8. What findings are strong enough to support a business test or follow-up analysis?

## Dataset

| Table | Rows | Purpose |
|---|---:|---|
| `menu_items` | 32 | Menu item, category, and price reference |
| `order_details` | 12,234 | Order-level line items |
| Distinct orders | 5,370 | Unique customer order transactions |
| Matched order-detail rows | 12,097 | Rows with a valid menu item match |
| Unmatched rows | 137 | `item_id = NULL` in the source CSV |

**Date range:** January 1, 2023 – March 31, 2023  
**Menu categories:** American, Asian, Mexican, Italian  
**Menu price range:** $5.00 – $19.95

## Data Quality & Analytical Treatment

The raw files were profiled before analysis.

Key checks include:

- row counts and date coverage
- duplicate `order_details_id` values
- NULL / missing values
- menu-item uniqueness
- referential integrity between `order_details` and `menu_items`
- price validity
- valid date/time values

The audit found:

- **0 duplicate `order_details_id` values**
- **137 unmatched item IDs**, all represented by the literal `NULL` value in the source CSV
- **All 32 known menu items appear in matched order data**

The 137 unmatched rows are **not deleted**. They remain in the raw dataset and are excluded from price-based revenue calculations because a reliable menu price cannot be established.

## Core Validated Metrics

Using matched menu-item records for revenue calculations:

| Metric | Result |
|---|---:|
| Total orders | **5,370** |
| Matched items sold | **12,097** |
| Average items per order | **2.25** |
| Revenue from matched items | **$159,217.90** |
| Average order value | **$29.65** |

### Revenue by Category

| Category | Revenue | Revenue Share |
|---|---:|---:|
| Italian | $49,462.70 | 31.07% |
| Asian | $46,720.65 | 29.34% |
| Mexican | $34,796.80 | 21.85% |
| American | $28,237.75 | 17.74% |

### Highest-Revenue Menu Items

1. **Korean Beef Bowl** — $10,554.60
2. **Spaghetti & Meatballs** — $8,436.50
3. **Tofu Pad Thai** — $8,149.00
4. **Cheeseburger** — $8,132.85
5. **Hamburger** — $8,054.90

### Highest-Volume Menu Items

1. **Hamburger** — 622 orders
2. **Edamame** — 620 orders
3. **Korean Beef Bowl** — 588 orders
4. **Cheeseburger** — 583 orders
5. **French Fries** — 571 orders

### Peak Ordering Hour

**12:00 PM** is the busiest hour, accounting for **644 orders (11.99% of all orders)**.

### Order Size

- 1 item: **38.23%**
- 2–3 items: **44.58%**
- 4–6 items: **14.77%**
- 7–10 items: **1.42%**
- 11+ items: **1.01%**

## Visual Summary

<img src="docs/revenue_by_category.svg" alt="Revenue by category" width="760">

<img src="docs/monthly_revenue.svg" alt="Monthly revenue" width="760">

<img src="docs/orders_by_hour.svg" alt="Orders by hour" width="760">

These visuals provide a quick executive view; the SQL files remain the source for reproducible calculations.

## SQL Analysis Areas

The SQL is organized into five analytical stages:

### 1. Setup
Schema creation and reproducible CSV loading instructions for MySQL 8.0.

### 2. Data Quality
Validation of row counts, duplicates, NULLs, referential integrity, dates, and prices.

### 3. Revenue Analysis
Revenue, AOV, category contribution, top/bottom revenue items, daily/monthly trends, price tiers, and week-over-week change.

### 4. Menu & Order Analysis
Menu-item demand, category performance, item rankings, order behavior, peak hours, order-size distribution, and basket pairings.

### 5. Advanced SQL
Window functions, cumulative revenue, rolling averages, ABC/Pareto analysis, anomaly detection, and revenue concentration.

The current repository contains **40 analysis/data-quality queries**, excluding schema setup and loading statements.

## Project Structure

<pre>
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
│   ├── orders_by_hour.svg
│   ├── monthly_revenue.svg
│   └── revenue_by_category.svg
└── README.md
</pre>

## How to Reproduce

### Requirements

- MySQL 8.0+
- `LOCAL INFILE` enabled if loading CSVs with `LOAD DATA LOCAL INFILE`

### 1. Create the schema

Run:

<pre>
mysql -u YOUR_USERNAME -p &lt; sql/01_setup/create_tables.sql
</pre>

### 2. Load the CSV files

The setup script includes MySQL loading examples. For `order_details.csv`, the source literal `NULL` item IDs are converted to SQL NULL during import so the raw record can be preserved without creating a false foreign-key match.

### 3. Run the analysis

Run the files in this order:

<pre>
sql/02_analysis/data_quality.sql
sql/02_analysis/revenue_analysis.sql
sql/02_analysis/menu_performance.sql
sql/02_analysis/order_behavior.sql
sql/03_advanced/advanced_analysis.sql
</pre>

### 4. Review findings

See:

- `analysis/key_findings.md`
- `analysis/recommendations.md`

## SQL Techniques Demonstrated

- JOINs
- CTEs
- GROUP BY and aggregation
- CASE expressions
- subqueries
- window functions
- `RANK()`, `ROW_NUMBER()`, and `NTILE()`
- `LAG()`
- cumulative totals
- rolling averages
- percentage contribution
- basket/item-pair analysis
- ABC/Pareto analysis
- standard deviation and percentile-style analysis using MySQL-compatible techniques

## Important Analytical Limitations

- The dataset covers only three months.
- There is no customer identifier, so this project analyzes **order behavior**, not individual customer retention or lifetime value.
- There is no quantity field; each row represents an order-detail line.
- 137 source rows have no usable menu-item match and are excluded from price-based revenue metrics.
- Revenue is treated as menu-price revenue; the dataset does not provide food cost, discounts, taxes, refunds, labor cost, or profit.
- Observed relationships are descriptive and should not be interpreted as causal effects without further testing.

## Recommendations

The recommendations in `analysis/recommendations.md` are framed as **testable business opportunities**, not guaranteed outcomes. Revenue impact, pricing elasticity, operational savings, and customer retention should be validated with additional data or controlled experiments.

## Author

**Golam Shakir**

## License

MIT License
