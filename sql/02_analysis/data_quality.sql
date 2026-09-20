-- =====================================================
-- Data Quality Audit
-- MySQL 8.0+
-- =====================================================
-- Purpose: validate the dataset before price-based analysis.
-- =====================================================

-- 1. Overall row counts and date coverage
SELECT
    COUNT(*) AS order_detail_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM order_details;

-- 2. Duplicate order-detail identifiers
SELECT
    order_details_id,
    COUNT(*) AS duplicate_count
FROM order_details
GROUP BY order_details_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 3. Missing values in order details
SELECT
    SUM(order_details_id IS NULL) AS null_order_detail_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_time IS NULL) AS null_order_time,
    SUM(item_id IS NULL) AS null_item_id
FROM order_details;

-- 4. Unmatched / missing menu item references
SELECT
    COUNT(*) AS unmatched_item_rows
FROM order_details od
LEFT JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
WHERE mi.menu_item_id IS NULL;

-- 5. Identify non-null item IDs that do not exist in the menu
SELECT DISTINCT
    od.item_id
FROM order_details od
LEFT JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL;

-- 6. Menu-item uniqueness and price validity
SELECT
    COUNT(*) AS menu_rows,
    COUNT(DISTINCT menu_item_id) AS distinct_menu_item_ids,
    SUM(price IS NULL) AS null_prices,
    SUM(price <= 0) AS non_positive_prices
FROM menu_items;

-- 7. Confirm every known menu item appears in matched order data
SELECT
    COUNT(*) AS menu_items_with_orders
FROM menu_items mi
WHERE EXISTS (
    SELECT 1
    FROM order_details od
    WHERE od.item_id = mi.menu_item_id
);

-- 8. Check for dates outside the expected project period
SELECT
    COUNT(*) AS out_of_range_rows
FROM order_details
WHERE order_date < '2023-01-01'
   OR order_date > '2023-03-31';
