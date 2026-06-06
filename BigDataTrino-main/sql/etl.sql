DROP TABLE IF EXISTS clickhouse.mydb.top10_products;
DROP TABLE IF EXISTS clickhouse.mydb.revenue_by_category;
DROP TABLE IF EXISTS clickhouse.mydb.avg_rating_reviews;
DROP TABLE IF EXISTS clickhouse.mydb.top10_customers;
DROP TABLE IF EXISTS clickhouse.mydb.customers_by_country;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_customer;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_time;
DROP TABLE IF EXISTS clickhouse.mydb.yearly_trends;
DROP TABLE IF EXISTS clickhouse.mydb.avg_order_by_month;
DROP TABLE IF EXISTS clickhouse.mydb.top5_stores;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_store_location;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_store;
DROP TABLE IF EXISTS clickhouse.mydb.top5_suppliers;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_supplier;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_supplier_country;
DROP TABLE IF EXISTS clickhouse.mydb.top_rated_products;
DROP TABLE IF EXISTS clickhouse.mydb.bottom_rated_products;
DROP TABLE IF EXISTS clickhouse.mydb.rating_sales_correlation;
DROP TABLE IF EXISTS clickhouse.mydb.products_by_rating;
DROP TABLE IF EXISTS clickhouse.mydb.products_by_review_count;
DROP TABLE IF EXISTS clickhouse.mydb.sales_by_product;

DROP TABLE IF EXISTS clickhouse.mydb.dim_date;
CREATE TABLE clickhouse.mydb.dim_date AS
SELECT DISTINCT
  cast(date_parse(sale_date, '%m/%d/%Y') AS varchar) AS date,
  cast(year(date_parse(sale_date, '%m/%d/%Y')) AS varchar) AS year,
  cast(month(date_parse(sale_date, '%m/%d/%Y')) AS varchar) AS month,
  cast(day(date_parse(sale_date, '%m/%d/%Y')) AS varchar) AS day
FROM (
  SELECT sale_date FROM postgresql.public.mock_data
  UNION ALL
  SELECT sale_date FROM clickhouse.mydb.sales
) t
WHERE date_parse(sale_date, '%m/%d/%Y') IS NOT NULL;

DROP TABLE IF EXISTS clickhouse.mydb.dim_customer;
CREATE TABLE clickhouse.mydb.dim_customer AS
SELECT
  CAST(sale_customer_id AS BIGINT)    AS customer_id,
  any_value(customer_first_name)      AS first_name,
  any_value(customer_last_name)       AS last_name,
  any_value(customer_age)             AS age,
  any_value(customer_email)           AS email,
  any_value(customer_country)         AS country
FROM (
  SELECT * FROM postgresql.public.mock_data
  UNION ALL
  SELECT * FROM clickhouse.mydb.sales
) t
GROUP BY CAST(sale_customer_id AS BIGINT);

DROP TABLE IF EXISTS clickhouse.mydb.dim_product;
CREATE TABLE clickhouse.mydb.dim_product AS
SELECT
  CAST(sale_product_id AS BIGINT)     AS product_id,
  any_value(product_name)             AS product_name,
  any_value(product_category)         AS category,
  any_value(product_brand)            AS brand,
  any_value(product_material)         AS material,
  any_value(product_size)             AS size,
  any_value(product_color)            AS color
FROM (
  SELECT * FROM postgresql.public.mock_data
  UNION ALL
  SELECT * FROM clickhouse.mydb.sales
) t
GROUP BY CAST(sale_product_id AS BIGINT);

DROP TABLE IF EXISTS clickhouse.mydb.dim_store;
CREATE TABLE clickhouse.mydb.dim_store AS
SELECT
  store_name                          AS store_name,
  any_value(store_location)           AS location,
  any_value(store_city)               AS city,
  any_value(store_state)              AS state,
  any_value(store_country)            AS country,
  any_value(store_phone)              AS phone,
  any_value(store_email)              AS email
FROM (
  SELECT * FROM postgresql.public.mock_data
  UNION ALL
  SELECT * FROM clickhouse.mydb.sales
) t
GROUP BY store_name;

DROP TABLE IF EXISTS clickhouse.mydb.dim_supplier;
CREATE TABLE clickhouse.mydb.dim_supplier AS
SELECT
  supplier_name                       AS supplier_name,
  any_value(supplier_contact)         AS contact,
  any_value(supplier_email)           AS email,
  any_value(supplier_phone)           AS phone,
  any_value(supplier_address)         AS address,
  any_value(supplier_city)            AS city,
  any_value(supplier_country)         AS country
FROM (
  SELECT * FROM postgresql.public.mock_data
  UNION ALL
  SELECT * FROM clickhouse.mydb.sales
) t
GROUP BY supplier_name;

DROP TABLE IF EXISTS clickhouse.mydb.fact_sales;
CREATE TABLE clickhouse.mydb.fact_sales AS
SELECT
  sale_id,
  sale_date,
  customer_id,
  product_id,
  store_name,
  supplier_name,
  quantity,
  unit_price,
  total_amount,
  rating,
  review_count
FROM (
  SELECT
    row_number() OVER (ORDER BY id) + 10000 AS sale_id,
    cast(date_parse(sale_date, '%m/%d/%Y') AS varchar) AS sale_date,
    CAST(sale_customer_id AS BIGINT)       AS customer_id,
    CAST(sale_product_id  AS BIGINT)       AS product_id,
    store_name                               AS store_name,
    supplier_name                            AS supplier_name,
    sale_quantity                            AS quantity,
    CAST(product_price    AS DECIMAL(18,2)) AS unit_price,
    sale_total_price                         AS total_amount,
    product_rating                           AS rating,
    product_reviews                          AS review_count
  FROM postgresql.public.mock_data

  UNION ALL

  SELECT
    row_number() OVER (ORDER BY id) AS sale_id,
    cast(date_parse(sale_date, '%m/%d/%Y') AS varchar) AS sale_date,
    CAST(sale_customer_id AS BIGINT)       AS customer_id,
    CAST(sale_product_id  AS BIGINT)       AS product_id,
    store_name                               AS store_name,
    supplier_name                            AS supplier_name,
    sale_quantity                            AS quantity,
    CAST(product_price    AS DECIMAL(18,2)) AS unit_price,
    sale_total_price                         AS total_amount,
    product_rating                           AS rating,
    product_reviews                          AS review_count
  FROM clickhouse.mydb.sales
) t;


DROP TABLE IF EXISTS clickhouse.mydb.mart_sales_by_product;
CREATE TABLE clickhouse.mydb.mart_sales_by_product AS
SELECT
  f.sale_id,
  p.product_id,
  p.product_name,
  p.category,
  p.brand,
  p.material,
  p.size,
  p.color,
  f.quantity,
  f.unit_price,
  f.total_amount,
  f.rating,
  f.review_count,
  f.sale_date,
  f.customer_id,
  f.store_name,
  f.supplier_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_product p ON f.product_id = p.product_id;

DROP TABLE IF EXISTS clickhouse.mydb.mart_sales_by_customer;
CREATE TABLE clickhouse.mydb.mart_sales_by_customer AS
SELECT
  f.sale_id,
  c.customer_id,
  concat(c.first_name, ' ', c.last_name) AS customer_name,
  c.age,
  c.email,
  c.country,
  f.total_amount,
  f.sale_date,
  f.product_id,
  f.store_name,
  f.supplier_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_customer c ON f.customer_id = c.customer_id;

DROP TABLE IF EXISTS clickhouse.mydb.mart_sales_by_time;
CREATE TABLE clickhouse.mydb.mart_sales_by_time AS
SELECT
  f.sale_id,
  d.date,
  d.year,
  d.month,
  d.day,
  f.total_amount,
  f.quantity,
  f.sale_date,
  f.customer_id,
  f.product_id,
  f.store_name,
  f.supplier_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_date d ON f.sale_date = d.date;

DROP TABLE IF EXISTS clickhouse.mydb.mart_sales_by_store;
CREATE TABLE clickhouse.mydb.mart_sales_by_store AS
SELECT
  f.sale_id,
  s.store_name,
  s.location,
  s.city,
  s.state,
  s.country,
  s.phone,
  s.email,
  f.total_amount,
  f.quantity,
  f.sale_date,
  f.customer_id,
  f.product_id,
  f.supplier_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_store s ON f.store_name = s.store_name;

DROP TABLE IF EXISTS clickhouse.mydb.mart_sales_by_supplier;
CREATE TABLE clickhouse.mydb.mart_sales_by_supplier AS
SELECT
  f.sale_id,
  sup.supplier_name,
  sup.contact,
  sup.email,
  sup.phone,
  sup.address,
  sup.city,
  sup.country,
  f.unit_price,
  f.total_amount,
  f.quantity,
  f.sale_date,
  f.customer_id,
  f.product_id,
  f.store_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_supplier sup ON f.supplier_name = sup.supplier_name;

DROP TABLE IF EXISTS clickhouse.mydb.mart_product_quality;
CREATE TABLE clickhouse.mydb.mart_product_quality AS
SELECT
  f.sale_id,
  p.product_id,
  p.product_name,
  p.category,
  p.brand,
  f.rating,
  f.review_count,
  f.quantity,
  f.total_amount,
  f.sale_date,
  f.customer_id,
  f.store_name,
  f.supplier_name
FROM clickhouse.mydb.fact_sales f
JOIN clickhouse.mydb.dim_product p ON f.product_id = p.product_id;
