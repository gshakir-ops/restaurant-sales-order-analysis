-- =====================================================
-- Menu Performance Analysis
-- MySQL 8.0+
-- =====================================================

-- 1. Most popular menu items by volume
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS items_sold,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM order_details od2
         JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id),
        2
    ) AS item_share_pct,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY items_sold DESC
LIMIT 10;

-- 2. Lowest-volume menu items
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS revenue
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY items_sold ASC, revenue ASC
LIMIT 10;

-- 3. Category performance
SELECT
    mi.category,
    COUNT(DISTINCT mi.menu_item_id) AS menu_items,
    COUNT(*) AS items_sold,
    ROUND(AVG(mi.price), 2) AS avg_menu_price,
    ROUND(SUM(mi.price), 2) AS revenue,
    ROUND(
        COUNT(*) / COUNT(DISTINCT mi.menu_item_id),
        2
    ) AS avg_items_sold_per_menu_item
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY revenue DESC;

-- 4. Price vs demand profile
-- Descriptive only: this query does not establish correlation or causation.
SELECT
    mi.item_name,
    mi.category,
    mi.price,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS revenue,
    CASE
        WHEN mi.price < 10 THEN 'Budget'
        WHEN mi.price < 15 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_tier
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category, mi.price
ORDER BY mi.price DESC, items_sold DESC;

-- 5. Item ranking within each category
WITH item_rankings AS (
    SELECT
        mi.category,
        mi.item_name,
        COUNT(*) AS items_sold,
        ROUND(SUM(mi.price), 2) AS revenue,
        RANK() OVER (
            PARTITION BY mi.category
            ORDER BY COUNT(*) DESC
        ) AS category_rank
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.category, mi.menu_item_id, mi.item_name
)
SELECT *
FROM item_rankings
ORDER BY category, category_rank, item_name;

-- 6. Best-selling item in each category
WITH ranked_items AS (
    SELECT
        mi.category,
        mi.item_name,
        COUNT(*) AS items_sold,
        RANK() OVER (
            PARTITION BY mi.category
            ORDER BY COUNT(*) DESC
        ) AS rank_in_category
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.category, mi.item_name
)
SELECT
    category,
    item_name AS top_item,
    items_sold
FROM ranked_items
WHERE rank_in_category = 1
ORDER BY items_sold DESC;

-- 7. High-volume vs high-revenue item matrix
SELECT
    mi.item_name,
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS revenue,
    CASE
        WHEN COUNT(*) >= (
            SELECT AVG(item_count)
            FROM (
                SELECT COUNT(*) AS item_count
                FROM order_details
                WHERE item_id IS NOT NULL
                GROUP BY item_id
            ) x
        )
        AND SUM(mi.price) >= (
            SELECT AVG(item_revenue)
            FROM (
                SELECT SUM(mi2.price) AS item_revenue
                FROM order_details od2
                JOIN menu_items mi2
                    ON od2.item_id = mi2.menu_item_id
                GROUP BY od2.item_id
            ) y
        ) THEN 'High Volume / High Revenue'
        WHEN COUNT(*) >= (
            SELECT AVG(item_count)
            FROM (
                SELECT COUNT(*) AS item_count
                FROM order_details
                WHERE item_id IS NOT NULL
                GROUP BY item_id
            ) x
        ) THEN 'High Volume / Lower Revenue'
        WHEN SUM(mi.price) >= (
            SELECT AVG(item_revenue)
            FROM (
                SELECT SUM(mi2.price) AS item_revenue
                FROM order_details od2
                JOIN menu_items mi2
                    ON od2.item_id = mi2.menu_item_id
                GROUP BY od2.item_id
            ) y
        ) THEN 'Lower Volume / High Revenue'
        ELSE 'Lower Volume / Lower Revenue'
    END AS performance_group
FROM order_details od
JOIN menu_items mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category
ORDER BY revenue DESC;

-- 8. Menu-item revenue contribution
WITH item_revenue AS (
    SELECT
        mi.menu_item_id,
        mi.item_name,
        mi.category,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.menu_item_id, mi.item_name, mi.category
)
SELECT
    item_name,
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM item_revenue
ORDER BY revenue DESC;
