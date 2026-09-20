-- =====================================================
-- Restaurant Order Analysis Setup
-- MySQL 8.0+
-- =====================================================
-- Creates a dedicated database, analytical tables, indexes,
-- and commented CSV-loading examples.
--
-- Run this script once for a fresh local analysis database.
-- =====================================================

CREATE DATABASE IF NOT EXISTS restaurant_orders;
USE restaurant_orders;

CREATE TABLE IF NOT EXISTS menu_items (
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_menu_price CHECK (price > 0)
);

CREATE TABLE IF NOT EXISTS order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    item_id INT NULL,
    CONSTRAINT fk_order_item
        FOREIGN KEY (item_id)
        REFERENCES menu_items(menu_item_id)
);

CREATE INDEX idx_order_date ON order_details(order_date);
CREATE INDEX idx_order_id ON order_details(order_id);
CREATE INDEX idx_order_item ON order_details(item_id);
CREATE INDEX idx_menu_category ON menu_items(category);

-- =====================================================
-- CSV LOAD EXAMPLES
-- =====================================================
-- Load menu_items first because order_details references it.
-- Adjust file paths to your local environment.
--
-- MySQL may require LOCAL INFILE to be enabled on the client
-- and/or server before using these statements.
--
-- LOAD DATA LOCAL INFILE 'data/raw/menu_items.csv'
-- INTO TABLE menu_items
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (menu_item_id, item_name, category, price);
--
-- The source order_details.csv contains 137 rows where
-- item_id is the literal text 'NULL'. Convert that text to
-- SQL NULL so the source record is preserved without creating
-- an invalid menu-item relationship.
--
-- LOAD DATA LOCAL INFILE 'data/raw/order_details.csv'
-- INTO TABLE order_details
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (order_details_id, order_id, order_date, order_time, @item_id)
-- SET item_id = NULLIF(@item_id, 'NULL');

-- =====================================================
-- POST-LOAD SANITY CHECKS
-- =====================================================

SELECT
    COUNT(*) AS menu_rows,
    COUNT(DISTINCT menu_item_id) AS distinct_menu_items,
    COUNT(DISTINCT category) AS categories,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM menu_items;

SELECT
    COUNT(*) AS order_detail_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    SUM(item_id IS NULL) AS rows_with_missing_item_id
FROM order_details;
