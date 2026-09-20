# Evidence-Based Recommendations

These recommendations are **testable business actions**, not guaranteed outcomes. The current dataset does not contain costs, margins, customer IDs, staffing data, wait times, discounts, refunds, or experiment results, so precise ROI and operational-impact projections are intentionally avoided.

## 1. Review Menu Performance Using Volume and Revenue

### Observation
Hamburger has the highest order volume (**622 items sold**), while Korean Beef Bowl generates the highest matched revenue (**$10,554.60**).

### Recommendation
Use both measures in recurring menu reviews:

- volume to understand demand
- revenue to understand sales contribution

### Validation
Track future volume, revenue, availability, and—when available—contribution margin before changing menu placement or assortment.

## 2. Resolve the 137 Missing Item References

### Observation
137 order-detail rows contain a missing `item_id`, affecting 137 source orders. Twenty-seven orders contain no matched menu item.

### Recommendation
Trace the source system or original transaction extract to determine whether these references are genuinely missing or were lost during export.

### Why it matters
Resolving the references would increase completeness of item-level revenue reporting.

## 3. Test Bundles Around Recurring Item Pairs

### Observation
Repeated pairs include:

- Hamburger + Edamame (78 orders)
- Cheeseburger + Edamame (75 orders)
- Hamburger + Cheeseburger (72 orders)
- Korean Beef Bowl + Edamame (68 orders)

The largest order-size group is also 2–3 items (44.58%).

### Recommendation
Pilot a small number of bundle or merchandising tests around high-frequency combinations.

### Validation
Measure:

- bundle attachment rate
- average order value
- units per order
- contribution margin per order
- cannibalization of standalone sales

Do not assume that historical pair frequency automatically creates incremental revenue.

## 4. Review Midday Service Capacity

### Observation
12:00 PM is the busiest hour with 647 source orders, and 11 AM–2 PM contains 36.42% of source orders.

### Recommendation
Review staffing, preparation, queue handling, and kitchen throughput around the lunch window.

### Validation
Collect operational metrics such as:

- ticket time
- queue time
- orders per labor hour
- cancellations
- peak-hour error rate

Only then estimate operational impact.

## 5. Monitor Category Mix

### Observation
Italian contributes 31.07% of matched revenue and Asian contributes 29.34%.

### Recommendation
Use category-level revenue and volume as recurring menu-review metrics.

### Validation
Combine category results with contribution margin, product availability, and any future customer-feedback data before adding or removing menu items.

## 6. Treat Price Findings as Descriptive

### Observation
The dataset shows demand across budget, mid-range, and premium price tiers, but it does not provide a controlled pricing experiment.

### Recommendation
Before changing prices, establish a test design and track volume, matched revenue, and contribution margin.

### Validation
Evaluate price changes using incremental profit rather than revenue alone.

## Suggested KPI Review

| KPI | Purpose |
|---|---|
| Matched revenue | Price-based sales performance |
| Source orders | Overall demand volume |
| Valued orders | Orders with reliable item-level pricing |
| Matched-order AOV | Basket value for valued orders |
| Items per valued order | Basket depth where item prices are known |
| Category revenue share | Menu mix |
| Top-item volume | Demand concentration |
| Top-item revenue share | Revenue concentration |
| Peak-hour orders | Operational planning |
| Missing item rows | Data quality |

## Limitations

This dataset is suitable for descriptive restaurant analytics, but not sufficient on its own for:

- profitability analysis
- customer retention or lifetime value
- staffing ROI
- service-time optimization
- price elasticity estimation
- causal impact measurement

These questions require additional data or controlled experiments.
