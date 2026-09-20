-- =====================================================
-- Menu Performance Analysis
-- =====================================================
-- Analyze menu item popularity, demand patterns,
-- and performance metrics by item and category
-- =====================================================

-- =====================================================
-- 1. TOP 10 MOST POPULAR ITEMS
-- =====================================================

SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM order_details)) * 100, 2) AS order_percentage,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY times_ordered DESC
LIMIT 10;


-- =====================================================
-- 2. LEAST POPULAR ITEMS (NEED ATTENTION)
-- =====================================================

SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM order_details)) * 100, 2) AS order_percentage
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY times_ordered ASC
LIMIT 10;


-- =====================================================
-- 3. CATEGORY PERFORMANCE RANKING
-- =====================================================

SELECT
    mi.category,
    COUNT(DISTINCT mi.menu_item_id) AS total_menu_items,
    COUNT(*) AS total_items_sold,
    ROUND(AVG(mi.price), 2) AS avg_item_price,
    SUM(mi.price) AS total_revenue,
    ROUND(COUNT(*) / COUNT(DISTINCT mi.menu_item_id), 2) AS items_sold_per_menu_item,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS category_rank
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY total_items_sold DESC;


-- =====================================================
-- 4. PRICE VS DEMAND ANALYSIS
-- =====================================================

-- Do higher-priced items sell less?
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    CASE
        WHEN mi.price < 10 THEN 'Budget'
        WHEN mi.price BETWEEN 10 AND 14.99 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_category,
    ROUND(COUNT(*) * mi.price, 2) AS revenue_contribution
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY mi.price DESC, times_ordered DESC;


-- =====================================================
-- 5. ITEM PERFORMANCE BY CATEGORY
-- =====================================================

-- Rank items within each category
WITH category_ranking AS (
    SELECT
        mi.category,
        mi.item_name,
        mi.price,
        COUNT(*) AS times_ordered,
        SUM(mi.price) AS total_revenue,
        RANK() OVER (PARTITION BY mi.category ORDER BY COUNT(*) DESC) AS rank_in_category
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY mi.category, mi.menu_item_id, mi.item_name, mi.price
)
SELECT * FROM category_ranking
ORDER BY category, rank_in_category;


-- =====================================================
-- 6. BEST SELLER BY CATEGORY
-- =====================================================

WITH category_best_sellers AS (
    SELECT
        mi.category,
        mi.item_name,
        COUNT(*) AS times_ordered,
        RANK() OVER (PARTITION BY mi.category ORDER BY COUNT(*) DESC) AS rank
    FROM order_details od
    JOIN menu_items mi ON od.item_id = mi.menu_item_id
    GROUP BY mi.category, mi.item_name
)
SELECT
    category,
    item_name AS best_seller,
    times_ordered
FROM category_best_sellers
WHERE rank = 1
ORDER BY times_ordered DESC;


-- =====================================================
-- 7. MENU ITEM EFFICIENCY SCORE
-- =====================================================

-- Calculate efficiency: revenue generated per appearance
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    SUM(mi.price) AS total_revenue,
    ROUND(AVG(mi.price), 2) AS avg_revenue_per_order,
    -- Efficiency score: combines popularity and price
    ROUND((COUNT(*) * 0.4 + (SUM(mi.price) / 100) * 0.6), 2) AS efficiency_score
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY efficiency_score DESC;


-- =====================================================
-- 8. UNDERPERFORMING ITEMS ANALYSIS
-- =====================================================

-- Items that appear in less than 1% of orders
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS times_ordered,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM order_details)) * 100, 2) AS order_percentage,
    'Consider removal or promotion' AS recommendation
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
HAVING COUNT(*) < (SELECT COUNT(*) FROM order_details) * 0.01
ORDER BY times_ordered ASC;


-- =====================================================
-- 9. COMPLETE MENU PERFORMANCE MATRIX
-- =====================================================

SELECT
    mi.category,
    mi.item_name,
    mi.price,
    COUNT(*) AS orders,
    SUM(mi.price) AS revenue,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM order_details)) * 100, 2) AS pct_of_total_orders,
    ROUND(AVG(mi.price), 2) AS avg_revenue_per_order,
    CASE
        WHEN COUNT(*) > (SELECT AVG(item_count) FROM (
            SELECT COUNT(*) AS item_count
            FROM order_details
            GROUP BY item_id
        ) AS avg_items) THEN 'High Performer'
        WHEN COUNT(*) BETWEEN
            (SELECT AVG(item_count) * 0.5 FROM (
                SELECT COUNT(*) AS item_count
                FROM order_details
                GROUP BY item_id
            ) AS avg_items)
            AND (SELECT AVG(item_count) FROM (
                SELECT COUNT(*) AS item_count
                FROM order_details
                GROUP BY item_id
            ) AS avg_items)
        THEN 'Average'
        ELSE 'Low Performer'
    END AS performance_category
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category, mi.menu_item_id, mi.item_name, mi.price
ORDER BY mi.category, orders DESC;
