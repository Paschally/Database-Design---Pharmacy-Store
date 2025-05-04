-- Create database
CREATE DATABASE IF NOT EXISTS pharm_sales;
USE pharm_sales;

-- Customer table
CREATE TABLE IF NOT EXISTS customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    email VARCHAR(255),
    city VARCHAR(45),
    state VARCHAR(45)
);

-- Product table
CREATE TABLE IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Store table
CREATE TABLE IF NOT EXISTS store (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    state VARCHAR(255)
);

-- Salesperson table
CREATE TABLE IF NOT EXISTS salesperson (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    salary INT NOT NULL,
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES store(id)
);

-- Sales table
CREATE TABLE IF NOT EXISTS sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    salesperson_id INT,
    store_id INT,
    sales_date DATETIME,
    quantity_purchased INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(id),
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (salesperson_id) REFERENCES salesperson(id),
    FOREIGN KEY (store_id) REFERENCES store(id)
);

-- Add a New Table: inventory
CREATE TABLE IF NOT EXISTS inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    last_updated DATETIME,
    quantity_in_stock INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (store_id) REFERENCES store(id),
    UNIQUE (product_id, store_id) -- Prevent duplicate records per store-product
);

-- restock_log table : To track restocking events over time (audit trail)
CREATE TABLE IF NOT EXISTS restock_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    quantity_added INT NOT NULL,
    restock_date DATETIME,
    restocked_by VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (store_id) REFERENCES store(id)
);

-- ----------------------------------------------------------------------------------------------------------------            
-- Insert into customer table
INSERT INTO customer (full_name, phone, email, city, state)
SELECT DISTINCT 
    customer,
    customer_mobile_number,
    customer_email,
    customer_city,
    customer_state
FROM lekwo_pharmacy_sales_inventory;

-- Insert into product table
INSERT INTO product (name, brand, category, price)
SELECT DISTINCT 
    product_name,
    drug_brand,
    drug_category,
    price
FROM lekwo_pharmacy_sales_inventory;

-- Insert into store table
INSERT INTO store (name, city, state)
SELECT DISTINCT 
    store_name,
    store_city,
    store_state
FROM lekwo_pharmacy_sales_inventory;

-- Insert into salesperson table
INSERT INTO salesperson (name, job_title, salary, store_id)
SELECT DISTINCT 
    employee,
    employee_role,
    employee_salary,
    s.id  -- store_id from store table
FROM lekwo_pharmacy_sales_inventory l
JOIN store s ON l.store_name = s.name;

-- Insert into
INSERT INTO inventory (product_id, store_id, last_updated, quantity_in_stock)
SELECT
    p.id,
    s.id,
    MAX(l.last_updated_date) AS last_updated,
    SUM(l.quantity_in_stock) AS quantity_in_stock
FROM lekwo_pharmacy_sales_inventory l
JOIN product p ON l.product_name = p.name AND l.drug_brand = p.brand
JOIN store s ON l.store_name = s.name
GROUP BY p.id, s.id;


-- Insert into sales table (with foreign keys)
INSERT INTO sales (customer_id, product_id, salesperson_id, store_id, sales_date, quantity_purchased)
SELECT
    c.id,
    p.id,
    sp.id,
    s.id,
    l.sale_date,
    l.quantity_purchased
FROM lekwo_pharmacy_sales_inventory l
JOIN customer c ON l.customer = c.full_name AND l.customer_email = c.email
JOIN product p ON l.product_name = p.name AND l.drug_brand = p.brand
JOIN store s ON l.store_name = s.name
JOIN salesperson sp ON l.employee = sp.name AND sp.store_id = s.id;

-- ----------------------------------------------------------------------------------------------------------------

-- DROP TABLE lekwo_pharmacy_sales;
-- ----------------------------------------------------------------------------------------------------------------

/*
Inventory Update Trigger:
When a sale is made, subtract quantity_purchased from inventory.quantity_in_stock
*/
DELIMITER $$
CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock - NEW.quantity_purchased
    WHERE product_id = NEW.product_id AND store_id = NEW.store_id;
END $$
DELIMITER ;

/*
Inventory Restock Trigger:
When new stock arrives → insert a new row in restock_log and add to inventory.quantity_in_stock
*/
DELIMITER $$
CREATE TRIGGER after_restock_insert
AFTER INSERT ON restock_log
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock + NEW.quantity_added
    WHERE product_id = NEW.product_id AND store_id = NEW.store_id;
END $$
DELIMITER ;

/*
Performance Enhancement
To enhance performance, we'll use indexing on foreign keys while querying:

CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_product_id ON sales(product_id);
CREATE INDEX idx_sales_salesperson_id ON sales(salesperson_id);
CREATE INDEX idx_sales_store_id ON sales(store_id);
*/
