-- =====================================================
-- Advanced SQL Analysis
-- MySQL 8.0+
-- =====================================================
-- Advanced techniques are used only where they improve
-- analytical interpretation.
-- =====================================================

-- 1. Revenue ranking within each category
WITH item_metrics AS (
    SELECT
        mi.category,
        mi.item_name,
        COUNT(*) AS items_sold,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.category, mi.item_name
)
SELECT
    category,
    item_name,
    items_sold,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        PARTITION BY category
        ORDER BY revenue DESC
    ) AS revenue_rank_in_category
FROM item_metrics
ORDER BY category, revenue_rank_in_category;

-- 2. Cumulative revenue contribution by menu item
WITH item_revenue AS (
    SELECT
        mi.item_name,
        mi.category,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.item_name, mi.category
)
SELECT
    item_name,
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / SUM(revenue) OVER (),
        2
    ) AS cumulative_revenue_share_pct
FROM item_revenue
ORDER BY revenue DESC;

-- 3. Month-over-month revenue movement
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(od.order_date, '%Y-%m') AS month,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY DATE_FORMAT(od.order_date, '%Y-%m')
),
with_lag AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue) * 100.0 /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_change_pct
FROM with_lag
ORDER BY month;

-- 4. 7-day moving average of daily revenue
WITH daily_revenue AS (
    SELECT
        od.order_date,
        SUM(mi.price) AS daily_revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_date
)
SELECT
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS seven_day_moving_avg
FROM daily_revenue
ORDER BY order_date;

-- 5. ABC / Pareto classification by menu-item revenue
WITH item_revenue AS (
    SELECT
        mi.item_name,
        mi.category,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.item_name, mi.category
),
scored AS (
    SELECT
        item_name,
        category,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM item_revenue
)
SELECT
    item_name,
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue * 100.0 / total_revenue, 2) AS revenue_share_pct,
    ROUND(cumulative_revenue * 100.0 / total_revenue, 2) AS cumulative_share_pct,
    CASE
        WHEN cumulative_revenue / total_revenue <= 0.80 THEN 'A'
        WHEN cumulative_revenue / total_revenue <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM scored
ORDER BY revenue DESC;

-- 6. Unusually large orders using a 2-standard-deviation rule
WITH order_sizes AS (
    SELECT
        od.order_id,
        COUNT(*) AS item_count,
        SUM(mi.price) AS order_revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
),
stats AS (
    SELECT
        AVG(item_count) AS avg_items,
        STDDEV_POP(item_count) AS stddev_items
    FROM order_sizes
)
SELECT
    os.order_id,
    os.item_count,
    ROUND(os.order_revenue, 2) AS order_revenue,
    ROUND(s.avg_items, 2) AS avg_items,
    ROUND(s.stddev_items, 2) AS stddev_items
FROM order_sizes os
CROSS JOIN stats s
WHERE os.item_count > s.avg_items + (2 * s.stddev_items)
ORDER BY os.item_count DESC;

-- 7. Revenue concentration by menu item
WITH item_revenue AS (
    SELECT
        mi.item_name,
        SUM(mi.price) AS revenue
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY mi.item_name
)
SELECT
    item_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM item_revenue
ORDER BY revenue DESC;

-- 8. Category mix over time
WITH monthly_category AS (
    SELECT
        DATE_FORMAT(od.order_date, '%Y-%m') AS month,
        mi.category,
        COUNT(*) AS items_sold
    FROM order_details od
    JOIN menu_items mi
        ON od.item_id = mi.menu_item_id
    GROUP BY DATE_FORMAT(od.order_date, '%Y-%m'), mi.category
)
SELECT
    month,
    category,
    items_sold,
    ROUND(
        items_sold * 100.0 /
        SUM(items_sold) OVER (PARTITION BY month),
        2
    ) AS category_share_pct,
    RANK() OVER (
        PARTITION BY month
        ORDER BY items_sold DESC
    ) AS monthly_category_rank
FROM monthly_category
ORDER BY month, monthly_category_rank;
