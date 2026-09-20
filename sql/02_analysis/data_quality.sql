-- =====================================================
-- Data Quality Audit
-- MySQL 8.0+
-- =====================================================
-- Run against the loaded restaurant_orders database.
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

-- 3. Duplicate full records (ignoring the technical row ID)
SELECT
    order_id,
    order_date,
    order_time,
    item_id,
    COUNT(*) AS duplicate_rows
FROM order_details
GROUP BY
    order_id,
    order_date,
    order_time,
    item_id
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC;

-- 4. Missing required fields
SELECT
    SUM(order_details_id IS NULL) AS null_order_detail_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_time IS NULL) AS null_order_time,
    SUM(item_id IS NULL) AS missing_item_id
FROM order_details;

-- 5. Missing / unmatched item rows and affected-row percentage
SELECT
    SUM(od.item_id IS NULL) AS missing_item_rows,
    ROUND(
        SUM(od.item_id IS NULL) * 100.0 / COUNT(*),
        2
    ) AS missing_item_row_pct
FROM order_details od;

-- 6. Orders affected by missing item IDs
WITH order_quality AS (
    SELECT
        od.order_id,
        SUM(od.item_id IS NULL) AS missing_item_rows,
        SUM(od.item_id IS NOT NULL AND mi.menu_item_id IS NOT NULL) AS matched_item_rows
    FROM order_details od
    LEFT JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
)
SELECT
    SUM(missing_item_rows > 0) AS affected_orders,
    ROUND(
        SUM(missing_item_rows > 0) * 100.0 / COUNT(*),
        2
    ) AS affected_order_pct,
    SUM(matched_item_rows = 0) AS orders_with_no_matched_items,
    ROUND(
        SUM(matched_item_rows = 0) * 100.0 / COUNT(*),
        2
    ) AS orders_with_no_matched_items_pct
FROM order_quality;

-- 7. Identify non-null item IDs that do not exist in the menu
SELECT DISTINCT
    od.item_id
FROM order_details od
LEFT JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL;

-- 8. Menu-item uniqueness and price validation
SELECT
    COUNT(*) AS menu_rows,
    COUNT(DISTINCT menu_item_id) AS distinct_menu_item_ids,
    SUM(menu_item_id IS NULL) AS null_menu_item_ids,
    SUM(price IS NULL) AS null_prices,
    SUM(price <= 0) AS non_positive_prices
FROM menu_items;

-- 9. Unexpected category values
SELECT
    category,
    COUNT(*) AS menu_items
FROM menu_items
WHERE category NOT IN ('American', 'Asian', 'Mexican', 'Italian')
GROUP BY category
ORDER BY menu_items DESC;

-- 10. Confirm every known menu item appears in matched order data
SELECT
    COUNT(*) AS menu_items_with_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM menu_items),
        2
    ) AS menu_items_covered_pct
FROM menu_items mi
WHERE EXISTS (
    SELECT 1
    FROM order_details od
    WHERE od.item_id = mi.menu_item_id
);

-- 11. Date validation
SELECT
    SUM(order_date IS NULL) AS null_dates,
    SUM(
        order_date < '2023-01-01'
        OR order_date > '2023-03-31'
    ) AS out_of_range_dates,
    MIN(order_date) AS min_date,
    MAX(order_date) AS max_date
FROM order_details;

-- 12. Time validation
SELECT
    SUM(order_time IS NULL) AS null_times,
    SUM(
        order_time < '00:00:00'
        OR order_time > '23:59:59'
    ) AS out_of_range_times
FROM order_details;
