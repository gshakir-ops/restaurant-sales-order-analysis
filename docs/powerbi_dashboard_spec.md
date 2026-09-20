# Power BI Dashboard Specification

This document describes a dashboard that can be built from the validated SQL outputs. **No Power BI `.pbix` file is included in this repository.**

## Data Model

Use:

- `menu_items` as the menu dimension
- `order_details` as the transaction fact table
- relationship: `menu_items.menu_item_id` → `order_details.item_id`

Missing `item_id` values should remain unmatched rather than being assigned a menu item.

## KPI Cards

1. Source Orders — 5,370
2. Valued Orders — 5,343
3. Matched Menu-Price Revenue — $159,217.90
4. Matched-Order AOV — $29.80
5. Missing Item Rows — 137

## Recommended Visuals

### Revenue
- Monthly matched revenue line chart
- Revenue by category bar chart
- Top 10 menu items by matched revenue

### Demand
- Source orders by hour
- Source orders by day of week
- Order-size distribution

### Menu
- Top items by volume
- Revenue contribution by item
- Category mix

### Basket
- Top item pairs by co-occurring orders

## Filters

- Order date
- Category
- Menu item

## Metric Definitions

**Matched Revenue**  
Sum of menu prices for order-detail rows whose `item_id` matches a known menu item.

**Valued Orders**  
Distinct `order_id` values with at least one matched menu item.

**Matched-Order AOV**  
Matched Revenue ÷ Valued Orders.

**Source Orders**  
Distinct `order_id` values in the raw `order_details` table.

## Presentation Guidance

Keep the dashboard focused on decision support rather than displaying every available SQL metric.

Use the same definitions and filters as the SQL analysis. Do not label matched revenue as total profit or imply that the dashboard contains customer-level analysis.

## Limitations to Show

The dashboard should make clear that:

- 137 source rows have missing `item_id`
- 27 source orders have no matched menu item
- revenue is menu-price revenue, not profit
- there is no customer identifier
- the observation period is January–March 2023
