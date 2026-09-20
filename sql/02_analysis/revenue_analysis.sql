-- =====================================================
-- Revenue Analysis
-- MySQL 8.0+
-- =====================================================
-- Revenue metrics use only order-detail rows with a valid
-- menu-item match so every revenue value has a known price.
-- =====================================================

-- 1. Overall revenue KPIs
SELECT
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS matched_items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value,
    ROUND(COUNT(*) / COUNT(DISTINCT od.order_id), 2) AS avg_items_per_order
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id;

-- 2. Revenue by category
SELECT
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(
        SUM(mi.price) * 100.0 /
        (SELECT SUM(mi2.price)
         FROM order_details od2
         JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id),
        2
    ) AS revenue_share_pct
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY total_revenue DESC;

-- 3. Top 10 revenue-generating items
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Bottom 10 revenue-generating items
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY total_revenue ASC
LIMIT 10;

-- 5. Daily revenue trend
SELECT
    od.order_date,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS daily_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY od.order_date
ORDER BY od.order_date;

-- 6. Monthly revenue summary
SELECT
    DATE_FORMAT(od.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS monthly_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY DATE_FORMAT(od.order_date, '%Y-%m')
ORDER BY month;

-- 7. Revenue by price tier
SELECT
    CASE
        WHEN mi.price < 10 THEN 'Budget (<$10)'
        WHEN mi.price < 15 THEN 'Mid-Range ($10-$14.99)'
        ELSE 'Premium ($15+)'
    END AS price_tier,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS total_revenue,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM order_details od2
         JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id),
        2
    ) AS item_share_pct
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY price_tier
ORDER BY total_revenue DESC;

-- 8. Week-over-week revenue change
WITH weekly_revenue AS (
    SELECT
        DATE_SUB(od.order_date, INTERVAL WEEKDAY(od.order_date) DAY) AS week_start,
        SUM(mi.price) AS weekly_revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY DATE_SUB(od.order_date, INTERVAL WEEKDAY(od.order_date) DAY)
),
weekly_with_lag AS (
    SELECT
        week_start,
        weekly_revenue,
        LAG(weekly_revenue) OVER (ORDER BY week_start) AS previous_week_revenue
    FROM weekly_revenue
)
SELECT
    week_start,
    ROUND(weekly_revenue, 2) AS weekly_revenue,
    ROUND(previous_week_revenue, 2) AS previous_week_revenue,
    ROUND(
        (weekly_revenue - previous_week_revenue) * 100.0 /
        NULLIF(previous_week_revenue, 0),
        2
    ) AS growth_pct
FROM weekly_with_lag
ORDER BY week_start;
