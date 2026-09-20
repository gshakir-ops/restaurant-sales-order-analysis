-- =====================================================
-- Restaurant Orders Database Setup
-- =====================================================
-- This script creates the database schema for restaurant
-- order analysis. Compatible with MySQL, PostgreSQL, SQLite
-- =====================================================

-- Create menu_items table
CREATE TABLE menu_items (
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Create order_details table
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    item_id INT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES menu_items(menu_item_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_order_date ON order_details(order_date);
CREATE INDEX idx_order_id ON order_details(order_id);
CREATE INDEX idx_category ON menu_items(category);

-- =====================================================
-- Data Loading Commands (Database-Specific)
-- =====================================================

-- MySQL:
-- LOAD DATA INFILE 'menu_items.csv'
-- INTO TABLE menu_items
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- PostgreSQL:
-- COPY menu_items(menu_item_id, item_name, category, price)
-- FROM '/path/to/menu_items.csv' DELIMITER ',' CSV HEADER;

-- SQLite:
-- Use .import command or DB Browser for SQLite

-- =====================================================
-- Sample Data Verification
-- =====================================================

-- Verify menu items loaded correctly
SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT category) AS total_categories,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM menu_items;

-- Verify order details loaded correctly
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT order_id) AS total_orders,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM order_details;

-- Verify data integrity (all item_ids should exist in menu_items)
SELECT
    COUNT(*) AS orphaned_records
FROM order_details od
LEFT JOIN menu_items mi ON od.item_id = mi.menu_item_id
WHERE mi.menu_item_id IS NULL;
