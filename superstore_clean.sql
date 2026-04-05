-- clean and normalise the dataset
-- first, i need to create a new table to store the cleaned data. after that, i will insert the data, clean it and normalise it.
select * from superstore;
CREATE TABLE ss_staging LIKE superstore;
-- insert the data into the staging table
INSERT INTO ss_staging 
SELECT * FROM superstore;
-- now, everything will be done in the staging table in order to preserve the original dataset
SELECT * 
FROM ss_staging;

-- i will start by properly formatting the date fields
SELECT row_id, order_date, STR_TO_DATE(order_date, '%d/%m/%Y') AS date_format
FROM ss_staging;

-- i came across some invalid date formats, so i will update those to the correct format
SELECT row_id, order_date, STR_TO_DATE(order_date, '%d/%m/%Y') AS date_format
FROM ss_staging
WHERE order_date = '4/15/2017';

SELECT row_id, order_date, STR_TO_DATE(order_date, '%d/%m/%Y') AS date_format
FROM ss_staging
WHERE order_date = '11/22/2015';

SELECT row_id, order_date, STR_TO_DATE(order_date, '%d/%m/%Y') AS date_format
FROM ss_staging
WHERE order_date = '5/13/2014';

-- update the invalid date formats to the correct format
UPDATE ss_staging
SET order_date = '15/4/2017'
WHERE order_date = '4/15/2017';

UPDATE ss_staging
SET order_date = '22/11/2015'
WHERE order_date = '11/22/2015';

UPDATE ss_staging
SET order_date = '13/5/2014'
WHERE order_date = '5/13/2014';

-- there are a lot fields that are in the wrong format, so i will update them all to the correct format with a case statement that will check and swap months and days if month > 12
SELECT order_date,
    CASE 
        WHEN CAST(SUBSTRING_INDEX(order_date, '/', 1) AS UNSIGNED) > 12  -- if first number > 12 then DD/MM/YYYY
            THEN STR_TO_DATE(order_date, '%d/%m/%Y')
        ELSE STR_TO_DATE(order_date, '%m/%d/%Y')
    END AS cleaned_date
FROM ss_staging;

-- update the order_date field with the new date format
UPDATE ss_staging
SET order_date = CASE
    -- if first number > 12 then DD/MM/YYYY
    WHEN CAST(SUBSTRING_INDEX(order_date, '/', 1) AS UNSIGNED) > 12 
        THEN STR_TO_DATE(order_date, '%d/%m/%Y')
    ELSE STR_TO_DATE(order_date, '%m/%d/%Y')
END;
-- alter the order_date field to be of type date
ALTER TABLE ss_staging
MODIFY order_date DATE;

-- now, i will do the same for the ship_date field
SELECT ship_date,
    CASE 
        WHEN CAST(SUBSTRING_INDEX(ship_date, '/', 1) AS UNSIGNED) > 12 
            THEN STR_TO_DATE(ship_date, '%d/%m/%Y')
        ELSE STR_TO_DATE(ship_date, '%m/%d/%Y')
    END AS cleaned_ship_date
FROM ss_staging;

-- update the ship_date field with the new date format
UPDATE ss_staging
SET ship_date = CASE
    -- if first number > 12 then DD/MM/YYYY
    WHEN CAST(SUBSTRING_INDEX(ship_date, '/', 1) AS UNSIGNED) > 12 
        THEN STR_TO_DATE(ship_date, '%d/%m/%Y')
    ELSE STR_TO_DATE(ship_date, '%m/%d/%Y')
END;
-- alter the ship_date field to be of type date
ALTER TABLE ss_staging
MODIFY ship_date DATE;

SELECT *
FROM ss_staging;

SELECT DISTINCT country
FROM ss_staging;
-- since all entries in the country field are the same, i will check for non numeric postal codes
SELECT postal_code
FROM ss_staging
WHERE postal_code REGEXP '^[0-9]+$' = 0;
-- there are none

-- i will check the city and region columns for any inconsistencies
SELECT DISTINCT city, TRIM(city) AS trimmed_city
FROM ss_staging;
-- there are no inconsistencies in the city column

SELECT DISTINCT region, TRIM(region) AS trimmed_region
FROM ss_staging;
-- there are no inconsistencies in the region column
-- trim the city and region columns to remove any leading or trailing spaces even though there are no inconsistencies, this will ensure that all entries are in the correct format
UPDATE ss_staging
SET city = TRIM(city),
    region = TRIM(region);

-- check for inconsistencies in the segment, category and sub_category columns
SELECT DISTINCT segment, TRIM(segment) AS trimmed_segment
FROM ss_staging;

SELECT DISTINCT category, TRIM(category) AS trimmed_category
FROM ss_staging;

SELECT DISTINCT sub_category, TRIM(sub_category) AS trimmed_sub_category
FROM ss_staging;

-- there are no inconsistencies in the segment, category and sub_category columns, but i will trim them to ensure that all entries are in the correct format
UPDATE ss_staging
SET segment = TRIM(segment),
    category = TRIM(category),
    sub_category = TRIM(sub_category);

-- i will standardise sales, discount and profit to 2 decimal places
SELECT sales, ROUND(sales, 2) AS rounded_sales
FROM ss_staging;

SELECT discount, ROUND(discount, 2) AS rounded_discount
FROM ss_staging;

SELECT profit, ROUND(profit, 2) AS rounded_profit
FROM ss_staging;

UPDATE ss_staging
SET sales = ROUND(sales, 2),
    discount = ROUND(discount, 2),
    profit = ROUND(profit, 2);

-- check for duplicates in ss_staging using row functions, partition by all columns and order by row_id to get the first occurrence of each duplicate using a cte
WITH cte AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY  order_id, order_date, ship_date, ship_mode,customer_id, customer_name, segment, country, city,
         state, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit
        ORDER BY row_id) AS row_num
    FROM ss_staging
)
SELECT *
FROM cte
WHERE row_num > 1;


-- create a table for deletion of duplicates
CREATE TABLE `ss_staging2` (
  `row_id` int DEFAULT NULL,
  `order_id` text,
  `order_date` date DEFAULT NULL,
  `ship_date` date DEFAULT NULL,
  `ship_mode` text,
  `customer_id` text,
  `customer_name` text,
  `segment` text,
  `country` text,
  `city` text,
  `state` text,
  `postal_code` int DEFAULT NULL,
  `region` text,
  `product_id` text,
  `category` text,
  `sub_category` text,
  `product_name` text,
  `sales` double DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `discount` double DEFAULT NULL,
  `profit` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- insert the records into the new table
INSERT INTO ss_staging2
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY  order_id, order_date, ship_date, ship_mode,customer_id, customer_name, segment, country, city,
         state, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit
        ORDER BY row_id) AS row_num
    FROM ss_staging;

-- delete the duplicates from the new table
DELETE FROM ss_staging2
WHERE row_num > 1;

-- check for null values in ss_staging2
SELECT 
    SUM(CASE WHEN order_id = '' THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN ship_mode = '' THEN 1 ELSE 0 END) AS ship_mode_nulls,
    SUM(CASE WHEN customer_id = '' THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_name = '' THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN segment = '' THEN 1 ELSE 0 END) AS segment_nulls,
    SUM(CASE WHEN country = '' THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN city = '' THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN state = '' THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN postal_code = '' THEN 1 ELSE 0 END) AS postal_code_nulls,
    SUM(CASE WHEN region = '' THEN 1 ELSE 0 END) AS region_nulls,
    SUM(CASE WHEN product_id = '' THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN category = '' THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN sub_category = '' THEN 1 ELSE 0 END) AS sub_category_nulls,
    SUM(CASE WHEN product_name = '' THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN sales = '' THEN 1 ELSE 0 END) AS sales_nulls,
    SUM(CASE WHEN quantity = '' THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN discount = '' THEN 1 ELSE 0 END) AS discount_nulls,
    SUM(CASE WHEN profit = '' THEN 1 ELSE 0 END) AS profit_nulls
FROM ss_staging2;
-- update the blanks in discount and profits to 0
UPDATE ss_staging2
SET discount = NULLIF(discount, ''),
    profit = NULLIF(profit, '');

-- i have to update field from TEXT to VARCHAR
ALTER TABLE ss_staging2
MODIFY order_id VARCHAR(255),
MODIFY ship_mode VARCHAR(255),
MODIFY customer_id VARCHAR(255),
MODIFY customer_name VARCHAR(255),
MODIFY segment VARCHAR(255),
MODIFY country VARCHAR(255),
MODIFY city VARCHAR(255),
MODIFY state VARCHAR(255),
MODIFY region VARCHAR(255),
MODIFY product_id VARCHAR(255),
MODIFY category VARCHAR(255),
MODIFY sub_category VARCHAR(255),
MODIFY product_name VARCHAR(255);


SELECT *
FROM ss_staging2
ORDER BY row_id;
-- drop row_num column from the new table
ALTER TABLE ss_staging2
DROP COLUMN row_num;

SELECT DISTINCT order_id, COUNT(*) AS count
FROM ss_staging2
GROUP BY order_id;

SELECT customer_id,
       COUNT(DISTINCT customer_name) AS name_count,
       COUNT(DISTINCT region) AS region_count
FROM ss_staging2
GROUP BY customer_id
HAVING name_count > 1 OR region_count > 1; -- since the region count varies, then region is not a good candidate for the customers table, but customer_name is consistent, so i will keep it in the customers table

SELECT product_id,
       COUNT(DISTINCT product_name) AS name_count,
       COUNT(DISTINCT category) AS category_count
FROM ss_staging2
GROUP BY product_id
HAVING name_count > 1 OR category_count > 1;