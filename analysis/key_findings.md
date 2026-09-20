# Key Findings

**Analysis period:** January 1 – March 31, 2023  
**Source rows:** 12,234 order-detail records  
**Source orders:** 5,370  
**Known menu items:** 32  
**Rows with missing item ID:** 137

## Executive Summary

The dataset contains **$159,217.90 in matched menu-price revenue** across **5,343 source orders with at least one matched menu item**.

Italian contributes the largest share of matched revenue, while Hamburger is the highest-volume menu item. Order activity is concentrated around midday and the early evening. The dataset also contains a material data-quality limitation: 137 order-detail rows have a missing item reference, and 27 source orders contain no matched menu item.

## 1. Revenue Performance

**Finding:** Matched menu-item revenue totaled **$159,217.90**. The corresponding matched-order AOV is **$29.80**.

**Interpretation:** Price-based revenue and AOV can be calculated for the 5,343 source orders that contain at least one matched menu item.

**Limitation:** The calculation excludes 27 orders with no matched menu item. Revenue also excludes costs, discounts, taxes, refunds, and labor.

### Revenue by category

| Category | Revenue | Share |
|---|---:|---:|
| Italian | $49,462.70 | 31.07% |
| Asian | $46,720.65 | 29.34% |
| Mexican | $34,796.80 | 21.85% |
| American | $28,237.75 | 17.74% |

**Finding:** Italian contributes the largest share of matched revenue at **31.07%**.

**Business interpretation:** Italian and Asian categories are important revenue contributors and are useful focus areas for ongoing menu-performance monitoring.

## 2. Menu Performance

### Highest revenue

| Item | Items Sold | Revenue |
|---|---:|---:|
| Korean Beef Bowl | 588 | $10,554.60 |
| Spaghetti & Meatballs | 470 | $8,436.50 |
| Tofu Pad Thai | 562 | $8,149.00 |
| Cheeseburger | 583 | $8,132.85 |
| Hamburger | 622 | $8,054.90 |

### Highest volume

| Item | Items Sold |
|---|---:|
| Hamburger | 622 |
| Edamame | 620 |
| Korean Beef Bowl | 588 |
| Cheeseburger | 583 |
| French Fries | 571 |

**Finding:** Hamburger is the highest-volume item, while Korean Beef Bowl generates the most matched revenue.

**Business interpretation:** Volume and revenue leaders are not identical, so menu decisions should consider both measures rather than volume alone.

## 3. Order Timing

**Finding:** **12:00 PM** is the busiest hour with **647 source orders (12.05%)**.

The **11 AM–2 PM** period contains **1,956 source orders (36.42%)**.

**Business interpretation:** Midday demand is concentrated enough to justify reviewing preparation and service capacity during the lunch window.

**Limitation:** The dataset contains no staffing, queue, ticket-time, cancellation, or service-level data, so operational impact cannot be quantified from these transactions alone.

## 4. Order Size

The observed source-order distribution is:

| Order size | Share |
|---|---:|
| 1 item | 38.23% |
| 2–3 items | 44.58% |
| 4–6 items | 14.77% |
| 7–10 items | 1.42% |
| 11+ items | 1.01% |

**Finding:** Orders containing **2–3 line items** form the largest group at **44.58%**.

**Business interpretation:** This pattern can inform bundle or cross-sell testing, but historical co-occurrence does not prove incremental AOV.

## 5. Basket Pairings

Top observed item pairs include:

- Hamburger + Edamame — 78 orders
- Cheeseburger + Edamame — 75 orders
- Hamburger + Cheeseburger — 72 orders
- Korean Beef Bowl + Edamame — 68 orders
- French Fries + Korean Beef Bowl — 66 orders

**Finding:** Several item pairs recur across orders.

**Business interpretation:** These combinations can be candidates for menu merchandising or bundle experiments.

**Limitation:** Pair frequency shows co-occurrence, not causation or incremental demand.

## 6. Monthly Revenue

| Month | Matched Revenue | Change vs. Prior Month |
|---|---:|---:|
| January | $53,816.95 | — |
| February | $50,790.35 | -5.62% |
| March | $54,610.60 | +7.52% |

**Finding:** Revenue declined in February and recovered in March. March was approximately **1.48% above January**.

**Interpretation:** The three-month sample does not establish a sustained growth trend.

## 7. Data Quality

**Finding:** **137 of 12,234 order-detail rows (1.12%)** have missing item IDs.

Those rows affect **137 of 5,370 source orders (2.55%)**. **27 orders (0.50%)** have no matched menu item and therefore cannot contribute to price-based revenue metrics.

**Treatment:** The raw records remain unchanged. Missing-item rows are excluded from price-based revenue analysis because their menu price cannot be established.

**Additional checks:** The current audit is designed to check duplicate IDs, full-record duplicates, required fields, category validity, date/time validity, price validity, and coverage of known menu items.

## Practical Takeaways

1. Monitor both item volume and revenue contribution when evaluating menu performance.
2. Use midday demand patterns to frame operational follow-up analysis.
3. Use recurring basket pairs as candidates for controlled merchandising tests.
4. Resolve the 137 missing item references before using the dataset for complete item-level revenue or profitability analysis.
5. Treat price-tier patterns as descriptive; measure actual price elasticity through controlled testing if needed.
