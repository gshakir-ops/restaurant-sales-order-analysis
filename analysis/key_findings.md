# Key Findings

**Analysis period:** January 1 – March 31, 2023  
**Source rows:** 12,234 order-detail records  
**Distinct orders:** 5,370  
**Known menu items:** 32  
**Unmatched item-ID rows:** 137

## Executive Summary

The restaurant generated **$159,217.90 in matched menu-price revenue** across 5,370 orders during the three-month period. Italian was the largest revenue category, while Hamburger was the highest-volume menu item.

The dataset also has a clear data-quality issue: 137 order-detail rows contain the literal `NULL` item ID. Those rows are preserved but excluded from price-based revenue calculations because their menu price cannot be established from the supplied reference table.

## 1. Revenue Performance

**Finding:** Matched menu-item revenue totaled **$159,217.90**, with an average order value of **$29.65**.

**Interpretation:** The dataset supports reliable order-level revenue and AOV reporting once unmatched item IDs are excluded.

**Limitation:** This is menu-price revenue, not profit. The dataset does not include cost, discounts, tax, refunds, or labor expense.

### Revenue by category

| Category | Revenue | Share |
|---|---:|---:|
| Italian | $49,462.70 | 31.07% |
| Asian | $46,720.65 | 29.34% |
| Mexican | $34,796.80 | 21.85% |
| American | $28,237.75 | 17.74% |

**Finding:** Italian contributes the largest share of matched revenue at **31.07%**, followed closely by Asian at **29.34%**.

**Business interpretation:** Italian and Asian menus are important revenue contributors and warrant continued performance monitoring.

## 2. Top Menu Items

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

**Finding:** Hamburger is the highest-volume item, while Korean Beef Bowl generates the most revenue.

**Business interpretation:** Volume and revenue leadership are not identical. Menu decisions should therefore consider both demand and revenue contribution.

## 3. Order Timing

**Finding:** 12:00 PM is the busiest hour with **644 orders (11.99% of all orders)**.

The 11 AM–2 PM lunch window accounts for approximately **36.2% of orders** based on matched item activity.

**Business interpretation:** Lunch demand is concentrated enough to justify examining staffing, preparation, and service capacity around the midday window.

**Limitation:** Transaction data does not contain wait times, staffing levels, kitchen throughput, or service-level metrics, so operational improvements cannot be quantified from this dataset alone.

## 4. Order Size

The observed order-size distribution is:

| Matched order size | Share of orders |
|---|---:|
| 1 item | 38.23% |
| 2–3 items | 44.58% |
| 4–6 items | 14.77% |
| 7–10 items | 1.42% |
| 11+ items | 1.01% |

**Finding:** Orders containing 2–3 items form the largest group.

**Business interpretation:** This pattern can be used to test bundle or cross-sell ideas, but the historical data alone does not prove that a bundle would increase AOV.

## 5. Basket Pairings

The most frequently observed item pairs include:

- Hamburger + Edamame — 78 orders
- Cheeseburger + Edamame — 75 orders
- Hamburger + Cheeseburger — 72 orders
- Korean Beef Bowl + Edamame — 68 orders
- French Fries + Korean Beef Bowl — 66 orders

**Finding:** Several pairs recur across orders, indicating opportunities for menu merchandising or bundle experiments.

**Limitation:** Co-occurrence does not establish that one item causes demand for another.

## 6. Monthly Revenue

| Month | Revenue | Change vs. prior month |
|---|---:|---:|
| January | $53,816.95 | — |
| February | $50,790.35 | -5.62% |
| March | $54,610.60 | +7.52% |

**Finding:** Revenue dipped in February and recovered in March. March revenue was approximately **1.48% above January**.

**Interpretation:** The three-month sample does not support a strong sustained growth claim.

## 7. Data Quality

**Finding:** 137 of 12,234 order-detail rows have an unmatched `item_id`, represented as the literal `NULL` value in the source file.

**Treatment:** The raw records are preserved. They are excluded from price-based revenue calculations because the menu price cannot be reliably identified.

**Additional checks:** No duplicate `order_details_id` values were found, and all 32 known menu items appear in matched order data.

## Practical Takeaways

1. Protect and monitor the strongest revenue contributors, especially Italian and Asian categories.
2. Evaluate high-volume items separately from high-revenue items.
3. Use the lunch-hour concentration to frame operational experiments, not to claim guaranteed staffing savings.
4. Test bundle ideas using the observed pairings and the large 2–3-item order segment.
5. Resolve or trace the 137 unmatched source records before using the dataset for profitability, item-level cost analysis, or more detailed menu optimization.
