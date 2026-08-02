-- now i can normalise the data by creating separate tables for customers, products and orders, and then linking them with foreign keys
-- create a customers table

CREATE TABLE customers_ss AS
SELECT 
    customer_id,
    MAX(customer_name) AS customer_name,
    MAX(segment) AS segment
FROM ss_staging2
GROUP BY customer_id;
-- i used the MAX function to get the customer_name and segment for each customer_id, since there are no inconsistencies in the customer_name and segment columns, this will not cause any issues
-- the MAX function grabs one value from the group, and since all values in the group are the same, it will not matter which value it grabs.

CREATE TABLE products_ss AS
SELECT 
    product_id,
    MAX(product_name) AS product_name,
    MAX(category) AS category,
    MAX(sub_category) AS sub_category
FROM ss_staging2
GROUP BY product_id;

CREATE TABLE orders_ss AS
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    country,
    region,
    postal_code, 
    sales,
    quantity,
    discount,
    profit
FROM ss_staging2;

SELECT *
FROM customers_ss;

SELECT *
FROM products_ss;

SELECT *
FROM orders_ss;

-- checking uniqueness of keys before making them primary keys
SELECT customer_id, COUNT(*)
FROM customers_ss
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products_ss
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT customer_id
FROM orders_ss
WHERE customer_id NOT IN (
    SELECT customer_id FROM customers_ss
); -- checking for any customer_id in orders_ss that does not exist in customers_ss, there are none

SELECT product_id
FROM orders_ss
WHERE product_id NOT IN (
    SELECT product_id FROM products_ss
); -- checking for any product_id in orders_ss that does not exist in products_ss, there are none

-- since all entries in the customer_id and product_id columns are unique, i can make them primary keys
ALTER TABLE customers_ss
ADD PRIMARY KEY (customer_id);

ALTER TABLE products_ss
ADD PRIMARY KEY (product_id);

-- lets check the uniqueness of the order_id column in orders_ss
SELECT order_id, COUNT(*)
FROM orders_ss
GROUP BY order_id
HAVING COUNT(*) > 1; -- there are duplicates in the order_id column, so i will not make it a primary key, instead i will make row_id the primary key since it is unique for each record.
ALTER TABLE orders_ss
ADD PRIMARY KEY (row_id);

-- now i will add foreign keys to link the tables together
ALTER TABLE orders_ss
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id) REFERENCES customers_ss(customer_id);

ALTER TABLE orders_ss
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id) REFERENCES products_ss(product_id);

SELECT *
FROM ss_staging2
ORDER BY row_id;

SELECT *
FROM customers_ss;

SELECT *
FROM products_ss;

SELECT *
FROM orders_ss;