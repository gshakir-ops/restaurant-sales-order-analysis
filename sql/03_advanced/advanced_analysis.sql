-- =====================================================
-- Advanced SQL Analysis
-- =====================================================
-- Complex queries demonstrating advanced SQL techniques:
-- window functions, CTEs, subqueries, and statistical analysis
-- =====================================================

-- =====================================================
-- 1. RUNNING TOTALS AND CUMULATIVE REVENUE
-- =====================================================

SELECT
    od.order_date,
    SUM(mi.price) AS daily_revenue,
    SUM(SUM(mi.price)) OVER (
        ORDER BY od.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue,
    ROUND(
        (SUM(mi.price) / SUM(SUM(mi.price)) OVER (
            ORDER BY od.order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )) * 100, 2
    ) AS percentage_of_total
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY od.order_date
ORDER BY od.order_date;


-- =====================================================
-- 2. RANKED ITEMS BY CATEGORY WITH PERCENTILE
-- =====================================================

SELECT
    mi.category,
    mi.item_name,
    COUNT(*) AS orders,
    PERCENT_RANK() OVER (
        PARTITION BY mi.category
        ORDER BY COUNT(*) DESC
    ) * 100 AS percentile_rank,
    NTILE(4) OVER (
        PARTITION BY mi.category
        ORDER BY COUNT(*) DESC
    ) AS quartile
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category, mi.item_name
ORDER BY mi.category, orders DESC;


-- =====================================================
-- 3. MOVING AVERAGE - 7 DAY REVENUE TREND
-- =====================================================

SELECT
    od.order_date,
    SUM(mi.price) AS daily_revenue,
    ROUND(
        AVG(SUM(mi.price)) OVER (
            ORDER BY od.order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_7day,
    ROUND(
        AVG(SUM(mi.price)) OVER (
            ORDER BY od.order_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_30day
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY od.order_date
ORDER BY od.order_date;


-- =====================================================
-- 4. CATEGORY PERFORMANCE WITH LAG COMPARISON
-- =====================================================

WITH daily_category_revenue AS (
    SELECT
        od.order_date,
        mi.category,
        SUM(mi.price) AS category_daily_revenue
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY od.order_date, mi.category
)
SELECT
    order_date,
    category,
    category_daily_revenue,
    LAG(category_daily_revenue) OVER (
        PARTITION BY category
        ORDER BY order_date
    ) AS previous_day_revenue,
    ROUND(
        ((category_daily_revenue - LAG(category_daily_revenue) OVER (
            PARTITION BY category
            ORDER BY order_date
        )) / LAG(category_daily_revenue) OVER (
            PARTITION BY category
            ORDER BY order_date
        )) * 100, 2
    ) AS day_over_day_change
FROM daily_category_revenue
ORDER BY category, order_date;


-- =====================================================
-- 5. CUSTOMER SEGMENTATION BY ORDER VALUE
-- =====================================================

WITH customer_segments AS (
    SELECT
        od.order_id,
        SUM(mi.price) AS order_total,
        COUNT(*) AS items_in_order,
        CASE
            WHEN SUM(mi.price) < 10 THEN 'Budget'
            WHEN SUM(mi.price) < 20 THEN 'Standard'
            WHEN SUM(mi.price) < 30 THEN 'Premium'
            ELSE 'Ultra-Premium'
        END AS segment,
        NTILE(4) OVER (ORDER BY SUM(mi.price)) AS quartile
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
)
SELECT
    segment,
    COUNT(*) AS orders_in_segment,
    ROUND(AVG(order_total), 2) AS avg_order_value,
    ROUND(AVG(items_in_order), 2) AS avg_items,
    MIN(order_total) AS min_order_value,
    MAX(order_total) AS max_order_value,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_segments)), 2) AS percentage
FROM customer_segments
GROUP BY segment
ORDER BY avg_order_value DESC;


-- =====================================================
-- 6. ITEM AFFINITY ANALYSIS
-- =====================================================

-- What items are purchased together most frequently?
WITH item_pairs AS (
    SELECT
        od1.order_id,
        od1.item_id AS item_1,
        od2.item_id AS item_2,
        mi1.item_name AS item_1_name,
        mi2.item_name AS item_2_name
    FROM order_details od1
    JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.item_id < od2.item_id
    JOIN menu_items mi1 ON od1.item_id = mi1.menu_item_id
    JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
)
SELECT
    item_1_name,
    item_2_name,
    COUNT(*) AS times_together,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS affinity_rank
FROM item_pairs
GROUP BY item_1_name, item_2_name
ORDER BY times_together DESC
LIMIT 20;


-- =====================================================
-- 7. STATISTICAL SUMMARY BY CATEGORY
-- =====================================================

SELECT
    mi.category,
    COUNT(*) AS total_items_sold,
    ROUND(AVG(mi.price), 2) AS mean_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mi.price) AS median_price,
    ROUND(STDDEV_POP(mi.price), 2) AS std_dev,
    MIN(mi.price) AS min_price,
    MAX(mi.price) AS max_price,
    ROUND(MAX(mi.price) - MIN(mi.price), 2) AS price_range
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY mean_price DESC;


-- =====================================================
-- 8. ANOMALY DETECTION - UNUSUAL ORDER PATTERNS
-- =====================================================

WITH order_stats AS (
    SELECT
        od.order_id,
        COUNT(*) AS item_count,
        SUM(mi.price) AS order_total,
        AVG(item_count) OVER () AS avg_items,
        STDDEV(item_count) OVER () AS stddev_items
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
)
SELECT
    order_id,
    item_count,
    order_total,
    ROUND(avg_items, 2) AS avg_items,
    ROUND(stddev_items, 2) AS stddev_items,
    CASE
        WHEN item_count > (avg_items + (2 * stddev_items)) THEN 'Unusually Large Order'
        WHEN item_count < (avg_items - (2 * stddev_items)) THEN 'Unusually Small Order'
        ELSE 'Normal'
    END AS order_classification
FROM order_stats
WHERE item_count > (avg_items + (2 * stddev_items))
   OR item_count < (avg_items - (2 * stddev_items))
ORDER BY item_count DESC;


-- =====================================================
-- 9. ABC ANALYSIS (PARETO) - 80/20 RULE
-- =====================================================

WITH item_revenue AS (
    SELECT
        mi.item_name,
        mi.category,
        SUM(mi.price) AS total_revenue,
        SUM(SUM(mi.price)) OVER (ORDER BY SUM(mi.price) DESC) AS cumulative_revenue,
        SUM(SUM(mi.price)) OVER () AS total_revenue_all
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY mi.item_name, mi.category
)
SELECT
    item_name,
    category,
    total_revenue,
    ROUND((total_revenue / total_revenue_all) * 100, 2) AS pct_of_total,
    ROUND((cumulative_revenue / total_revenue_all) * 100, 2) AS cumulative_pct,
    CASE
        WHEN (cumulative_revenue / total_revenue_all) <= 0.80 THEN 'A - Core (80%)'
        WHEN (cumulative_revenue / total_revenue_all) <= 0.95 THEN 'B - Important (80-95%)'
        ELSE 'C - Rest (5%)'
    END AS abc_classification
FROM item_revenue
ORDER BY total_revenue DESC;


-- =====================================================
-- 10. CATEGORY MIX ANALYSIS - TIME SERIES
-- =====================================================

SELECT
    od.order_date,
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY od.order_date)), 2
    ) AS category_percentage,
    RANK() OVER (
        PARTITION BY od.order_date
        ORDER BY COUNT(*) DESC
    ) AS rank_by_date
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY od.order_date, mi.category
ORDER BY od.order_date DESC, items_sold DESC;


-- =====================================================
-- 11. REVENUE CONCENTRATION ANALYSIS
-- =====================================================

-- Herfindahl-Hirschman Index (HHI) - market concentration
WITH item_shares AS (
    SELECT
        mi.item_name,
        (SUM(mi.price) / (SELECT SUM(price) FROM order_details od2 JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id)) AS market_share
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY mi.item_name
)
SELECT
    ROUND(SUM(market_share * market_share) * 10000, 2) AS hhi_index,
    CASE
        WHEN SUM(market_share * market_share) * 10000 < 1500 THEN 'Competitive'
        WHEN SUM(market_share * market_share) * 10000 < 2500 THEN 'Moderate Concentration'
        ELSE 'High Concentration'
    END AS market_concentration
FROM item_shares;


-- =====================================================
-- 12. SEASONAL DECOMPOSITION - WEEKLY PATTERN
-- =====================================================

SELECT
    CASE EXTRACT(DOW FROM od.order_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    COUNT(DISTINCT od.order_id) AS orders,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    ROUND(
        (COUNT(DISTINCT od.order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM order_details)), 2
    ) AS pct_of_weekly_orders,
    ROUND(
        COUNT(DISTINCT od.order_id) /
        (COUNT(DISTINCT od.order_id) OVER ()), 2
    ) AS weight_factor
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY EXTRACT(DOW FROM od.order_date)
ORDER BY COUNT(DISTINCT od.order_id) DESC;
