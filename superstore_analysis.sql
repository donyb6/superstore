-- Superstore Analysis

-- using joins to view all data from orders, customers and products tables
SELECT c.customer_id, c.customer_name, p.product_id, p.product_name, p.category, p.sub_category,  
        o.order_id, o.order_date, o.ship_date, o.ship_mode, o.country, o.region, o.postal_code, o.sales, o.quantity, o.discount, o.profit
FROM customers_ss AS c
JOIN orders_ss AS o 
    ON c.customer_id = o.customer_id
JOIN products_ss AS p
    ON o.product_id = p.product_id
ORDER BY o.order_date;

-- total amount of sales per month and year
SELECT MONTH(order_date) AS month, YEAR(order_date) AS year, ROUND(SUM(sales), 2) AS total_sales
FROM orders_ss
GROUP BY month, year
ORDER BY year, MONTH(order_date);

-- total amount of sales per category and sub-category
SELECT p.category, p.sub_category, ROUND(SUM(o.sales), 2) AS total_sales
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, p.sub_category;

-- total amount of sales per region and country
SELECT o.region, o.country, ROUND(SUM(o.sales), 2) AS total_sales
FROM orders_ss AS o
GROUP BY o.region, o.country
ORDER BY o.region, o.country;

-- total amount of sales per ship mode
SELECT o.ship_mode, ROUND(SUM(o.sales), 2) AS total_sales
FROM orders_ss AS o
GROUP BY o.ship_mode
ORDER BY o.ship_mode;

-- total amount of sales per customer
SELECT c.customer_id, c.customer_name, ROUND(SUM(o.sales), 2) AS total_sales
FROM customers_ss AS c
JOIN orders_ss AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC;

-- total amount of sales, number of orders and quantity per product
SELECT p.product_id, p.product_name, ROUND(SUM(o.sales), 2) AS total_sales, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;

-- total amount of sales, number of orders and quantity per year
SELECT YEAR(order_date) AS year, ROUND(SUM(sales), 2) AS total_sales, COUNT(order_id) AS num_orders, SUM(quantity) AS total_quantity
FROM orders_ss
GROUP BY year
ORDER BY year;

-- total amount of sales, number of orders and quantity per month
SELECT MONTH(order_date) AS month, YEAR(order_date) AS year, ROUND(SUM(sales), 2) AS total_sales, COUNT(order_id) AS num_orders, SUM(quantity) AS total_quantity  
FROM orders_ss
GROUP BY month, year
ORDER BY year, month;

-- total amount of sales, number of orders and quantity per year, category and sub-category
SELECT YEAR(order_date) AS year, p.category, p.sub_category, ROUND(SUM(o.sales), 2) AS total_sales, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category
ORDER BY year, p.category, p.sub_category;

-- total amount of sales, number of orders and quantity per year, region and country
SELECT YEAR(order_date) AS year, o.region, o.country, ROUND(SUM(o.sales), 2) AS total_sales, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_quantity
FROM orders_ss AS o
GROUP BY year, o.region, o.country
ORDER BY year, o.region, o.country;

-- price of all products by calculating from sales, quantity and discount where discount is not null
SELECT p.product_id, p.product_name, ROUND(SUM(o.sales) / SUM(o.quantity * (1 - o.discount)), 2) AS price
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
WHERE o.discount IS NOT NULL
GROUP BY p.product_id, p.product_name
ORDER BY price;

-- price of all products by calculating from sales, quantity and discount where discount is null
SELECT p.product_id, p.product_name, ROUND(SUM(o.sales) / SUM(o.quantity), 2) AS price, o.discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
WHERE o.discount IS NULL
GROUP BY p.product_id, p.product_name, o.discount
ORDER BY price;

-- total amount of sales, number of orders and quantity per year, category, sub-category and ship mode
SELECT YEAR(order_date) AS year, p.category, p.sub_category, o.ship_mode, ROUND(SUM(o.sales), 2) AS total_sales, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category, o.ship_mode
ORDER BY year, p.category, p.sub_category, o.ship_mode;

-- total amount of sales, number of orders and quantity per year, region, country and ship mode
SELECT YEAR(order_date) AS year, o.region, o.country, o.ship_mode, ROUND(SUM(o.sales), 2) AS total_sales, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_quantity
FROM orders_ss AS o
GROUP BY year, o.region, o.country, o.ship_mode
ORDER BY year, o.region, o.country, o.ship_mode;

-- total quantity of products sold per year, category, sub-category and ship mode
SELECT YEAR(order_date) AS year, p.category, p.sub_category, o.ship_mode, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category, o.ship_mode
ORDER BY year, p.category, p.sub_category, o.ship_mode;

SELECT SUM(quantity) AS total_quantity
FROM orders_ss;

-- top 10 customers with the most quantity of products sold
SELECT c.customer_id, c.customer_name, SUM(o.quantity) AS total_quantity
FROM customers_ss AS c
JOIN orders_ss AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_quantity DESC
LIMIT 10;

-- customers with the least quantity of products sold
SELECT c.customer_id, c.customer_name, SUM(o.quantity) AS total_quantity
FROM customers_ss AS c
JOIN orders_ss AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_quantity ASC
LIMIT 10;

-- top 10 products with the most quantity sold
SELECT p.product_id, p.product_name, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 10;

-- products with the least quantity sold
SELECT p.product_id, p.product_name, SUM(o.quantity) AS total_quantity
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity ASC
LIMIT 10;



-- null and not null discounts
SELECT SUM(quantity) AS total_quantity
FROM orders_ss
WHERE discount IS NOT NULL;

SELECT SUM(quantity) AS total_quantity
FROM orders_ss
WHERE discount IS NULL;

-- total quantity of products sold per year, category, sub-category and ship mode where discount is null
SELECT YEAR(order_date) AS year, p.category, p.sub_category, o.ship_mode, SUM(o.quantity) AS total_quantity_null_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
WHERE o.discount IS NULL
GROUP BY year, p.category, p.sub_category, o.ship_mode
ORDER BY year, p.category, p.sub_category, o.ship_mode;

-- total quantity of products sold per year, region, country and ship mode where discount is not null
SELECT YEAR(order_date) AS year, o.region, o.country, o.ship_mode, SUM(o.quantity) AS total_quantity_not_null_discount
FROM orders_ss AS o
WHERE o.discount IS NOT NULL
GROUP BY year, o.region, o.country, o.ship_mode
ORDER BY year, o.region, o.country, o.ship_mode;

-- comparing total quantity of products sold per year, category, sub-category where discount is null and not null
SELECT YEAR(order_date) AS year, p.category, p.sub_category,
SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) AS total_quantity_no_discount,
SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) AS total_quantity_with_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category
ORDER BY year, p.category, p.sub_category;

-- using the above query to calculate the percentage of products sold with discount and without discount per year, category and sub-category
SELECT YEAR(order_date) AS year, p.category, p.sub_category,
ROUND(SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) * 100.0 / SUM(o.quantity), 2) AS percentage_no_discount,
ROUND(SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) * 100.0 / SUM(o.quantity), 2) AS percentage_with_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category
ORDER BY year, p.category, p.sub_category;

-- the majority of categories whether with discount or without discount per year, category and sub-category
SELECT YEAR(order_date) AS year, p.category, p.sub_category,
CASE 
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) > SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'No Discount'
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) < SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'With Discount'
    ELSE 'Equal'
END AS majority_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category
ORDER BY year, p.category, p.sub_category;

WITH count_cte AS(
    SELECT YEAR(order_date) AS year, p.category, p.sub_category,
CASE 
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) > SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'No Discount'
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) < SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'With Discount'
    ELSE 'Equal'
END AS majority_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY year, p.category, p.sub_category
ORDER BY year, p.category, p.sub_category
)
SELECT 
    COUNT(CASE WHEN majority_discount = 'No Discount' THEN 1 END) AS count_no_discount,
    COUNT(CASE WHEN majority_discount = 'With Discount' THEN 1 END) AS count_with_discount,
    COUNT(CASE WHEN majority_discount = 'Equal' THEN 1 END) AS count_equal
FROM count_cte;

-- for only category and subcategory
SELECT p.category, p.sub_category,
CASE 
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) > SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'No Discount'
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) < SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'With Discount'
    ELSE 'Equal'
END AS majority_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, p.sub_category;

WITH count_cte AS(
    SELECT p.category, p.sub_category,
CASE 
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) > SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'No Discount'
    WHEN SUM(CASE WHEN o.discount IS NULL THEN o.quantity ELSE 0 END) < SUM(CASE WHEN o.discount IS NOT NULL THEN o.quantity ELSE 0 END) THEN 'With Discount'
    ELSE 'Equal'
END AS majority_discount
FROM products_ss AS p
JOIN orders_ss AS o ON p.product_id = o.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, p.sub_category
)
SELECT 
    COUNT(CASE WHEN majority_discount = 'No Discount' THEN 1 END) AS count_no_discount,
    COUNT(CASE WHEN majority_discount = 'With Discount' THEN 1 END) AS count_with_discount,
    COUNT(CASE WHEN majority_discount = 'Equal' THEN 1 END) AS count_equal
FROM count_cte;



-- time series analysis
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales
FROM orders_ss
GROUP BY year, month
ORDER BY year, month;

SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales, COUNT(order_id) AS num_orders, SUM(quantity) AS total_quantity
FROM orders_ss
WHERE discount IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales, COUNT(order_id) AS num_orders, SUM(quantity) AS total_quantity
FROM orders_ss
WHERE discount IS NULL
GROUP BY year, month
ORDER BY year, month;

-- using lag() to calculate the month-over-month growth rate of sales
SELECT year, month, total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
    (total_sales - LAG(total_sales) OVER (ORDER BY year, month)) / LAG(total_sales) OVER (ORDER BY year, month) AS growth_rate
FROM (
    SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales
    FROM orders_ss
    GROUP BY year, month
) AS monthly_sales
ORDER BY year, month;

-- using lag() to calculate the month-over-month growth rate of sales in percentage
SELECT year, month, total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year, month)) * 100.0 / LAG(total_sales) OVER (ORDER BY year, month), 2) AS growth_rate_percentage
FROM (
    SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales
    FROM orders_ss
    GROUP BY year, month
) AS monthly_sales
ORDER BY year, month;

-- profits field in orders_ss
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(profit), 2) AS total_profit
FROM orders_ss
GROUP BY year, month
ORDER BY year, month;

-- sum profits and losses per month and year
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, 
    ROUND(SUM(CASE WHEN profit >= 0 THEN profit ELSE 0 END), 2) AS total_profit,
    ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2) AS total_loss
FROM orders_ss
GROUP BY year, month
ORDER BY year, month;

-- sum profits and losses per year
SELECT YEAR(order_date) AS year, 
    ROUND(SUM(CASE WHEN profit >= 0 THEN profit ELSE 0 END), 2) AS total_profit,
    ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2) AS total_loss
FROM orders_ss
GROUP BY year
ORDER BY year;

-- average profit per month and year
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(AVG(profit), 2) AS avg_profit
FROM orders_ss
GROUP BY year, month
ORDER BY year, month;

-- average profit per year
SELECT YEAR(order_date) AS year, ROUND(AVG(profit), 2) AS avg_profit
FROM orders_ss
GROUP BY year
ORDER BY year;

-- count of months with positive growth rate, negative growth rate and zero growth rate
SELECT 
    COUNT(CASE WHEN growth_rate > 0 THEN 1 END) AS positive_growth_months,
    COUNT(CASE WHEN growth_rate < 0 THEN 1 END) AS negative_growth_months,
    COUNT(CASE WHEN growth_rate = 0 THEN 1 END) AS zero_growth_months
FROM (
    SELECT year, month, total_sales,
        (total_sales - LAG(total_sales) OVER (ORDER BY year, month)) / LAG(total_sales) OVER (ORDER BY year, month) AS growth_rate
    FROM (
        SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, ROUND(SUM(sales), 2) AS total_sales
        FROM orders_ss
        GROUP BY year, month
    ) AS monthly_sales
) AS growth_rates;

-- growth rate of sales per year
SELECT year, total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year)) * 100.0 / LAG(total_sales) OVER (ORDER BY year), 2) AS growth_rate_percentage
FROM (
    SELECT YEAR(order_date) AS year, ROUND(SUM(sales), 2) AS total_sales
    FROM orders_ss
    GROUP BY year
) AS yearly_sales
ORDER BY year;