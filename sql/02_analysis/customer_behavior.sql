-- =====================================================
-- Customer Behavior Analysis
-- =====================================================
-- Analyze ordering patterns, peak hours, basket size,
-- and customer preferences
-- =====================================================

-- =====================================================
-- 1. PEAK ORDERING HOURS
-- =====================================================

SELECT
    EXTRACT(HOUR FROM od.order_time) AS hour_of_day,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND(COUNT(*) / COUNT(DISTINCT od.order_id), 2) AS avg_items_per_order
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY EXTRACT(HOUR FROM od.order_time)
ORDER BY hour_of_day;


-- =====================================================
-- 2. BUSIEST TIME PERIODS
-- =====================================================

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 6 AND 10 THEN 'Breakfast (6AM-10AM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 11 AND 14 THEN 'Lunch (11AM-2PM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 15 AND 17 THEN 'Afternoon (3PM-5PM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 18 AND 21 THEN 'Dinner (6PM-9PM)'
        ELSE 'Late Night (9PM+)'
    END AS time_period,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items,
    SUM(mi.price) AS period_revenue,
    ROUND(AVG(mi.price), 2) AS avg_item_price
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY
    CASE
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 6 AND 10 THEN 'Breakfast (6AM-10AM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 11 AND 14 THEN 'Lunch (11AM-2PM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 15 AND 17 THEN 'Afternoon (3PM-5PM)'
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 18 AND 21 THEN 'Dinner (6PM-9PM)'
        ELSE 'Late Night (9PM+)'
    END
ORDER BY total_orders DESC;


-- =====================================================
-- 3. ORDER SIZE DISTRIBUTION
-- =====================================================

SELECT
    CASE
        WHEN item_count = 1 THEN 'Single Item (1)'
        WHEN item_count BETWEEN 2 AND 3 THEN 'Small Order (2-3)'
        WHEN item_count BETWEEN 4 AND 6 THEN 'Medium Order (4-6)'
        WHEN item_count BETWEEN 7 AND 10 THEN 'Large Order (7-10)'
        ELSE 'Extra Large (11+)'
    END AS order_size,
    COUNT(*) AS number_of_orders,
    ROUND((COUNT(*) / (SELECT COUNT(DISTINCT order_id) FROM order_details)) * 100, 2) AS percentage
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM order_details
    GROUP BY order_id
) AS order_sizes
GROUP BY
    CASE
        WHEN item_count = 1 THEN 'Single Item (1)'
        WHEN item_count BETWEEN 2 AND 3 THEN 'Small Order (2-3)'
        WHEN item_count BETWEEN 4 AND 6 THEN 'Medium Order (4-6)'
        WHEN item_count BETWEEN 7 AND 10 THEN 'Large Order (7-10)'
        ELSE 'Extra Large (11+)'
    END
ORDER BY number_of_orders DESC;


-- =====================================================
-- 4. AVERAGE ORDER VALUE BY HOUR
-- =====================================================

SELECT
    EXTRACT(HOUR FROM od.order_time) AS hour,
    COUNT(DISTINCT od.order_id) AS total_orders,
    SUM(mi.price) AS hourly_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value,
    ROUND(COUNT(*) / COUNT(DISTINCT od.order_id), 2) AS avg_items_per_order
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY EXTRACT(HOUR FROM od.order_time)
ORDER BY avg_order_value DESC;


-- =====================================================
-- 5. CATEGORY PREFERENCES BY TIME OF DAY
-- =====================================================

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 6 AND 14 THEN 'Daytime (6AM-2PM)'
        ELSE 'Evening (2PM-10PM)'
    END AS time_of_day,
    mi.category,
    COUNT(*) AS items_ordered,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
        PARTITION BY CASE
            WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 6 AND 14 THEN 'Daytime (6AM-2PM)'
            ELSE 'Evening (2PM-10PM)'
        END
    )), 2) AS percentage_in_period
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY
    CASE
        WHEN EXTRACT(HOUR FROM od.order_time) BETWEEN 6 AND 14 THEN 'Daytime (6AM-2PM)'
        ELSE 'Evening (2PM-10PM)'
    END,
    mi.category
ORDER BY time_of_day, items_ordered DESC;


-- =====================================================
-- 6. BASKET ANALYSIS - TOP ITEM PAIRS
-- =====================================================

-- Find items frequently ordered together
SELECT
    mi1.item_name AS item_1,
    mi2.item_name AS item_2,
    COUNT(DISTINCT od1.order_id) AS times_ordered_together
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.item_id < od2.item_id
JOIN menu_items mi1 ON od1.item_id = mi1.menu_item_id
JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
GROUP BY mi1.item_name, mi2.item_name
ORDER BY times_ordered_together DESC
LIMIT 15;


-- =====================================================
-- 7. SINGLE vs MULTI-ITEM ORDERS
-- =====================================================

WITH order_counts AS (
    SELECT
        order_id,
        COUNT(*) AS items_in_order
    FROM order_details
    GROUP BY order_id
)
SELECT
    CASE
        WHEN items_in_order = 1 THEN 'Single Item Orders'
        ELSE 'Multi-Item Orders'
    END AS order_type,
    COUNT(*) AS number_of_orders,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_counts)), 2) AS percentage,
    ROUND(AVG(items_in_order), 2) AS avg_items
FROM order_counts
GROUP BY
    CASE
        WHEN items_in_order = 1 THEN 'Single Item Orders'
        ELSE 'Multi-Item Orders'
    END;


-- =====================================================
-- 8. DAY OF WEEK ANALYSIS
-- =====================================================

SELECT
    CASE EXTRACT(DOW FROM order_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(*) AS total_items,
    SUM(mi.price) AS daily_revenue,
    ROUND(SUM(mi.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY
    CASE EXTRACT(DOW FROM order_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END
ORDER BY daily_revenue DESC;


-- =====================================================
-- 9. ORDER VALUE DISTRIBUTION
-- =====================================================

WITH order_totals AS (
    SELECT
        od.order_id,
        SUM(mi.price) AS order_total
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
)
SELECT
    CASE
        WHEN order_total < 15 THEN 'Low ($0-$14.99)'
        WHEN order_total BETWEEN 15 AND 24.99 THEN 'Medium ($15-$24.99)'
        WHEN order_total BETWEEN 25 AND 39.99 THEN 'High ($25-$39.99)'
        ELSE 'Premium ($40+)'
    END AS order_value_range,
    COUNT(*) AS number_of_orders,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_totals)), 2) AS percentage,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals
GROUP BY
    CASE
        WHEN order_total < 15 THEN 'Low ($0-$14.99)'
        WHEN order_total BETWEEN 15 AND 24.99 THEN 'Medium ($15-$24.99)'
        WHEN order_total BETWEEN 25 AND 39.99 THEN 'High ($25-$39.99)'
        ELSE 'Premium ($40+)'
    END
ORDER BY avg_order_value;


-- =====================================================
-- 10. REPEAT PATTERNS - SAME ORDER COMBOS
-- =====================================================

-- Find the most common order combinations
WITH order_combos AS (
    SELECT
        order_id,
        STRING_AGG(item_id::TEXT, ',' ORDER BY item_id) AS combo_signature
    FROM order_details
    GROUP BY order_id
)
SELECT
    combo_signature,
    COUNT(*) AS times_repeated
FROM order_combos
GROUP BY combo_signature
HAVING COUNT(*) > 1
ORDER BY times_repeated DESC
LIMIT 10;
