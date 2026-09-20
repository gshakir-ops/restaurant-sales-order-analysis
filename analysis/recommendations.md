# Evidence-Based Recommendations

These recommendations are **hypotheses and testable actions**, not guaranteed outcomes. The dataset does not contain costs, margins, customer IDs, staffing data, wait times, discounts, or experiment results, so precise ROI and operational-impact projections are intentionally avoided.

## 1. Prioritize Menu Decisions Using Two Metrics

### Observation
Hamburger has the highest order volume (**622**), while Korean Beef Bowl has the highest revenue (**$10,554.60**).

### Recommendation
Use a two-axis menu review:

- **Volume leaders**: protect availability and monitor operational demand.
- **Revenue leaders**: monitor pricing, availability, and contribution to total revenue.

### Validation
Track future item volume, revenue, and margin before making removal or expansion decisions.

---

## 2. Investigate the 137 Unmatched Item-Detail Rows

### Observation
137 source rows have `item_id = NULL`, so their menu price cannot be established.

### Recommendation
Trace the source system or original transaction extract to determine whether these are genuine missing item references or incomplete exports.

### Why it matters
Resolving the records would improve the completeness of item-level revenue analysis.

---

## 3. Test Bundles Around Existing Item Pairings

### Observation
Repeated item pairs include:

- Hamburger + Edamame (78)
- Cheeseburger + Edamame (75)
- Hamburger + Cheeseburger (72)
- Korean Beef Bowl + Edamame (68)

The largest order-size segment is also 2–3 items (44.58%).

### Recommendation
Pilot a small number of bundle placements or combo offers around high-frequency pairings.

### Validation
Compare:

- bundle attachment rate
- average order value
- units per order
- gross margin per order
- cannibalization of standalone items

Do not assume that historical co-occurrence automatically creates incremental revenue.

---

## 4. Review Midday Capacity

### Observation
12:00 PM is the busiest hour at 644 orders, and the 11 AM–2 PM window represents roughly 36.2% of orders.

### Recommendation
Review staffing, prep, and order throughput around the lunch window.

### Validation
Collect operational metrics such as:

- ticket time
- queue time
- orders per labor hour
- order cancellations
- peak-hour error rate

Only then estimate an operational impact.

---

## 5. Monitor Category Mix

### Observation
Italian represents 31.07% of matched revenue and Asian 29.34%.

### Recommendation
Use category-level revenue and volume trends as a recurring menu-review metric.

### Validation
Track category share monthly and combine it with contribution margin, customer feedback, and item availability before adding or removing products.

---

## 6. Treat Price Findings as Descriptive, Not Causal

The current dataset shows meaningful demand across budget, mid-range, and premium price tiers, but it does not provide a valid experiment for measuring price elasticity.

### Recommendation
Before changing prices on top-selling items, establish a controlled test design and track volume, revenue, and margin.

A price change should be evaluated on **incremental gross profit**, not revenue alone.

---

## Suggested KPI Review

A repeatable weekly or monthly review should track:

| KPI | Purpose |
|---|---|
| Revenue | Overall sales performance |
| Orders | Demand volume |
| AOV | Basket value |
| Items per order | Basket depth |
| Category revenue share | Menu mix |
| Top-item volume | Demand concentration |
| Top-item revenue share | Revenue concentration |
| Peak-hour orders | Operational planning |
| Unmatched item rows | Data quality |

## Limitations

This dataset is useful for descriptive restaurant analytics, but it is not sufficient on its own for:

- profitability analysis
- customer retention analysis
- customer lifetime value
- staffing ROI
- price elasticity estimation
- causal impact measurement

Those questions require additional data or controlled experiments.
