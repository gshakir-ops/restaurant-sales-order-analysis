-- =====================================================
-- Revenue Analysis
-- =====================================================
-- Analyze total revenue, average order value, and
-- revenue performance by category and time period
-- =====================================================

-- =====================================================
-- 1. OVERALL REVENUE METRICS
-- =====================================================

-- Total Revenue, Orders, Items, AOV
SELECT
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(mi.price) AS total_revenue,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value_aov,
    ROUND(COUNT(*) / COUNT(DISTINCT od.order_id), 2) AS avg_items_per_order
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id;


-- =====================================================
-- 2. REVENUE BY CATEGORY
-- =====================================================

-- Revenue and performance metrics by cuisine category
SELECT
    mi.category,
    COUNT(*) AS items_sold,
    SUM(mi.price) AS total_revenue,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS revenue_per_order,
    ROUND((SUM(mi.price) / (
        SELECT SUM(price)
        FROM order_details od2
        JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
    )) * 100, 2) AS revenue_percentage
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY total_revenue DESC;


-- =====================================================
-- 3. TOP 10 REVENUE-GENERATING ITEMS
-- =====================================================

SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    SUM(mi.price) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(*), 2) AS revenue_per_order
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY total_revenue DESC
LIMIT 10;


-- =====================================================
-- 4. BOTTOM 10 REVENUE-GENERATING ITEMS
-- =====================================================

SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    SUM(mi.price) AS total_revenue,
    ROUND(SUM(mi.price) / COUNT(*), 2) AS revenue_per_order
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY total_revenue ASC
LIMIT 10;


-- =====================================================
-- 5. DAILY REVENUE TREND
-- =====================================================

-- Revenue by date for trend analysis
SELECT
    od.order_date,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items,
    SUM(mi.price) AS daily_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY od.order_date
ORDER BY od.order_date;


-- =====================================================
-- 6. MONTHLY REVENUE SUMMARY
-- =====================================================

SELECT
    EXTRACT(MONTH FROM od.order_date) AS month_number,
    CASE EXTRACT(MONTH FROM od.order_date)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
    END AS month_name,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items,
    SUM(mi.price) AS monthly_revenue,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY EXTRACT(MONTH FROM od.order_date)
ORDER BY month_number;


-- =====================================================
-- 7. REVENUE BY PRICE TIER
-- =====================================================

-- Analyze revenue by price ranges
SELECT
    CASE
        WHEN mi.price < 10 THEN 'Budget ($0-$9.99)'
        WHEN mi.price BETWEEN 10 AND 14.99 THEN 'Mid-Range ($10-$14.99)'
        WHEN mi.price BETWEEN 15 AND 19.99 THEN 'Premium ($15-$19.99)'
        ELSE 'Ultra-Premium ($20+)'
    END AS price_tier,
    COUNT(*) AS items_sold,
    SUM(mi.price) AS total_revenue,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND((SUM(mi.price) / (
        SELECT SUM(price)
        FROM order_details od2
        JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
    )) * 100, 2) AS revenue_percentage
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY
    CASE
        WHEN mi.price < 10 THEN 'Budget ($0-$9.99)'
        WHEN mi.price BETWEEN 10 AND 14.99 THEN 'Mid-Range ($10-$14.99)'
        WHEN mi.price BETWEEN 15 AND 19.99 THEN 'Premium ($15-$19.99)'
        ELSE 'Ultra-Premium ($20+)'
    END
ORDER BY avg_item_price DESC;


-- =====================================================
-- 8. REVENUE GROWTH ANALYSIS
-- =====================================================

-- Week-over-week revenue comparison
WITH weekly_revenue AS (
    SELECT
        DATE_TRUNC('week', od.order_date) AS week_start,
        SUM(mi.price) AS weekly_revenue
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY DATE_TRUNC('week', od.order_date)
)
SELECT
    week_start,
    weekly_revenue,
    LAG(weekly_revenue) OVER (ORDER BY week_start) AS previous_week_revenue,
    ROUND(
        ((weekly_revenue - LAG(weekly_revenue) OVER (ORDER BY week_start)) /
        LAG(weekly_revenue) OVER (ORDER BY week_start)) * 100, 2
    ) AS growth_percentage
FROM weekly_revenue
ORDER BY week_start;
