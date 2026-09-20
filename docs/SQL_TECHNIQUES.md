# SQL Techniques Used in This Project

This document outlines the SQL techniques and concepts demonstrated throughout the Restaurant Orders Analytics project.

---

## 📚 Beginner to Intermediate Concepts

### 1. Basic Aggregation Functions
**Location**: All analysis files

```sql
COUNT(*), COUNT(DISTINCT), SUM(), AVG(), MAX(), MIN()
```

**Purpose**: Calculate key metrics like total orders, revenue, and averages

---

### 2. JOIN Operations
**Location**: All analysis files

```sql
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
```

**Purpose**: Combine data from multiple tables (orders + menu items)

**Types Used**:
- INNER JOIN (default)
- LEFT JOIN (for finding orphaned records)

---

### 3. GROUP BY & Aggregation
**Location**: `revenue_analysis.sql`, `menu_performance.sql`

```sql
GROUP BY mi.category
HAVING COUNT(*) > 100
```

**Purpose**: Segment data by categories, items, time periods

---

### 4. CASE Statements
**Location**: `customer_behavior.sql`, `advanced_analysis.sql`

```sql
CASE 
    WHEN mi.price < 10 THEN 'Budget'
    WHEN mi.price BETWEEN 10 AND 14.99 THEN 'Mid-Range'
    ELSE 'Premium'
END AS price_tier
```

**Purpose**: Create custom categories and classifications

---

## 🎯 Intermediate Concepts

### 5. Common Table Expressions (CTEs)
**Location**: `advanced_analysis.sql`

```sql
WITH category_ranking AS (
    SELECT ...
)
SELECT * FROM category_ranking
```

**Purpose**: Break complex queries into readable steps, create reusable subqueries

---

### 6. Window Functions
**Location**: `advanced_analysis.sql`

```sql
-- Running totals
SUM(mi.price) OVER (
    ORDER BY od.order_date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)

-- Rankings
RANK() OVER (ORDER BY COUNT(*) DESC)
NTILE(4) OVER (PARTITION BY category ORDER BY COUNT(*) DESC)
```

**Types Used**:
- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`
- `NTILE()` - Divide data into quartiles
- `LAG()` - Compare with previous row
- `SUM() OVER()` - Running totals
- `AVG() OVER()` - Moving averages

---

### 7. Date/Time Functions
**Location**: `customer_behavior.sql`, `revenue_analysis.sql`

```sql
EXTRACT(HOUR FROM od.order_time)
EXTRACT(MONTH FROM od.order_date)
EXTRACT(DOW FROM od.order_date)
DATE_TRUNC('week', od.order_date)
```

**Purpose**: Analyze patterns by hour, day, month, week

---

### 8. Subqueries
**Location**: All analysis files

```sql
-- In WHERE clause
WHERE COUNT(*) < (SELECT AVG(item_count) FROM (...))

-- In SELECT clause
(SELECT COUNT(*) FROM order_details) AS total_orders
```

**Purpose**: Compare values to calculated benchmarks

---

## 🚀 Advanced Concepts

### 9. Percentile Functions
**Location**: `advanced_analysis.sql`

```sql
PERCENT_RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC)
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mi.price)
```

**Purpose**: Statistical analysis, identify outliers

---

### 10. Self Joins
**Location**: `customer_behavior.sql` (Basket Analysis)

```sql
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id 
    AND od1.item_id < od2.item_id
```

**Purpose**: Find items ordered together (market basket analysis)

---

### 11. Statistical Functions
**Location**: `advanced_analysis.sql`

```sql
STDDEV_POP(mi.price)  -- Standard deviation
AVG() OVER()          -- Moving averages
```

**Purpose**: Advanced statistical analysis

---

### 12. String Aggregation
**Location**: `customer_behavior.sql`

```sql
STRING_AGG(item_id::TEXT, ',' ORDER BY item_id)
```

**Purpose**: Combine multiple rows into one string (order signatures)

---

## 📊 Query Patterns

### Pattern 1: Percentage of Total
```sql
ROUND((COUNT(*) / (SELECT COUNT(*) FROM table)) * 100, 2) AS percentage
```

### Pattern 2: Ranked Items Within Category
```sql
RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rank_in_category
```

### Pattern 3: Day-over-Day Change
```sql
LAG(value) OVER (ORDER BY date) AS previous_value,
ROUND(((current - LAG(value) OVER (ORDER BY date)) / 
    LAG(value) OVER (ORDER BY date)) * 100, 2) AS pct_change
```

### Pattern 4: Moving Average
```sql
AVG(value) OVER (
    ORDER BY date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS moving_avg_7day
```

---

## 🎓 Learning Path

**Beginner** (Start Here):
1. Basic SELECT statements
2. WHERE clauses
3. ORDER BY
4. Basic aggregations (COUNT, SUM, AVG)
5. GROUP BY

**Intermediate**:
1. JOINs (INNER, LEFT, RIGHT)
2. Subqueries
3. CASE statements
4. CTEs (Common Table Expressions)
5. Date/Time functions

**Advanced**:
1. Window functions
2. Percentile functions
3. Self joins
4. Statistical functions
5. Complex CTEs

---

## 💡 Best Practices Demonstrated

1. **Use CTEs for readability** - Break complex queries into steps
2. **Add comments** - Document what each section does
3. **Use meaningful aliases** - `od` for order_details, `mi` for menu_items
4. **Format queries** - Proper indentation and line breaks
5. **Test incrementally** - Build queries step by step
6. **Consider performance** - Indexes on JOIN columns

---

## 🔧 Database Compatibility

All queries are written in **Standard SQL** and compatible with:
- ✅ PostgreSQL
- ✅ MySQL 8.0+
- ✅ SQL Server
- ✅ SQLite (with minor modifications)
- ✅ Oracle

**Note**: Some functions may need syntax adjustments for specific databases:
- `STRING_AGG()` → `GROUP_CONCAT()` in MySQL/SQLite
- `EXTRACT()` → `DATEPART()` in SQL Server
- `::TEXT` type cast → `CAST(item_id AS VARCHAR)` in some databases

---

**Last Updated**: September 2026
