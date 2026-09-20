-- =====================================================
-- Order Behavior Analysis
-- MySQL 8.0+
-- =====================================================
-- This file intentionally uses "order behavior" rather than
-- "customer behavior" because the dataset has no customer ID.
-- =====================================================

-- 1. Orders by hour
SELECT
    HOUR(order_time) AS hour_of_day,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS matched_items_sold,
    ROUND(COUNT(*) / COUNT(DISTINCT order_id), 2) AS avg_items_per_order
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;

-- 2. Peak service windows
SELECT
    CASE
        WHEN HOUR(order_time) BETWEEN 11 AND 14 THEN 'Lunch (11AM-2PM)'
        WHEN HOUR(order_time) BETWEEN 18 AND 21 THEN 'Dinner (6PM-9PM)'
        WHEN HOUR(order_time) BETWEEN 15 AND 17 THEN 'Afternoon (3PM-5PM)'
        ELSE 'Other'
    END AS service_window,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM order_details),
        2
    ) AS order_share_pct
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY service_window
ORDER BY total_orders DESC;

-- 3. Order-size distribution
WITH order_sizes AS (
    SELECT
        order_id,
        COUNT(*) AS matched_item_count
    FROM order_details
    WHERE item_id IS NOT NULL
    GROUP BY order_id
)
SELECT
    CASE
        WHEN matched_item_count = 1 THEN '1 item'
        WHEN matched_item_count BETWEEN 2 AND 3 THEN '2-3 items'
        WHEN matched_item_count BETWEEN 4 AND 6 THEN '4-6 items'
        WHEN matched_item_count BETWEEN 7 AND 10 THEN '7-10 items'
        ELSE '11+ items'
    END AS order_size,
    COUNT(*) AS number_of_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_sizes),
        2
    ) AS order_share_pct
FROM order_sizes
GROUP BY order_size
ORDER BY number_of_orders DESC;

-- 4. Average order value by hour
SELECT
    HOUR(od.order_time) AS hour_of_day,
    COUNT(DISTINCT od.order_id) AS total_orders,
    ROUND(SUM(mi.price), 2) AS revenue,
    ROUND(
        SUM(mi.price) / COUNT(DISTINCT od.order_id),
        2
    ) AS avg_order_value
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY HOUR(od.order_time)
ORDER BY avg_order_value DESC;

-- 5. Category mix by broad time period
WITH timed_orders AS (
    SELECT
        CASE
            WHEN HOUR(order_time) BETWEEN 11 AND 14 THEN 'Lunch'
            WHEN HOUR(order_time) BETWEEN 18 AND 21 THEN 'Dinner'
            ELSE 'Other'
        END AS service_window,
        category,
        COUNT(*) AS item_count
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY service_window, category
)
SELECT
    service_window,
    category,
    item_count,
    ROUND(
        item_count * 100.0 /
        SUM(item_count) OVER (PARTITION BY service_window),
        2
    ) AS category_share_pct
FROM timed_orders
ORDER BY service_window, item_count DESC;

-- 6. Top item pairs appearing in the same order
SELECT
    mi1.item_name AS item_1,
    mi2.item_name AS item_2,
    COUNT(DISTINCT od1.order_id) AS orders_together
FROM order_details od1
JOIN order_details od2
    ON od1.order_id = od2.order_id
   AND od1.item_id < od2.item_id
JOIN menu_items mi1
    ON od1.item_id = mi1.menu_item_id
JOIN menu_items mi2
    ON od2.item_id = mi2.menu_item_id
GROUP BY mi1.menu_item_id, mi1.item_name, mi2.menu_item_id, mi2.item_name
ORDER BY orders_together DESC
LIMIT 10;

-- 7. Orders by day of week
SELECT
    DAYNAME(od.order_date) AS day_of_week,
    COUNT(DISTINCT od.order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT od.order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM order_details),
        2
    ) AS order_share_pct
FROM order_details od
GROUP BY DAYOFWEEK(od.order_date), DAYNAME(od.order_date)
ORDER BY total_orders DESC;

-- 8. Daily revenue and AOV by day of week
SELECT
    DAYNAME(od.order_date) AS day_of_week,
    COUNT(DISTINCT od.order_id) AS total_orders,
    ROUND(SUM(mi.price), 2) AS revenue,
    ROUND(
        SUM(mi.price) / COUNT(DISTINCT od.order_id),
        2
    ) AS avg_order_value
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY DAYOFWEEK(od.order_date), DAYNAME(od.order_date)
ORDER BY revenue DESC;
