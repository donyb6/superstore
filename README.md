**Superstore Sales Data Analysis (SQL)**
Project Overview
This project involves cleaning, transforming, and analyzing a retail transactional dataset using SQL.

* Data Cleaning
Handled inconsistent date formats
Cleaned postal codes using REGEXP
Managed NULL values in discount field

* Data Modeling (Normalisation)
The dataset was normalized into three tables:
-Customers
  customer_id (Primary Key)
  customer_name
  segment
-Products
  product_id (Primary Key)
  product_name
  category
  sub_category
-Orders
  row_id
  customer_id (Foreign Key)
  product_id (Foreign Key)
  order_date, sales, quantity, etc.
  
* Relationships
One customer to many orders
One product to many orders

* Analysis Performed
Sales trends by region and category
Discount vs non-discount quantity analysis
Growth rate analysis

* Tools Used
MySQL
SQL (Joins, CTEs, Aggregations, Window Functions)

* Dataset
Superstore dataset (cleaned version included)
