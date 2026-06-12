# BigDataTrino - ETL с использованием Trino
Лабораторная работа №4: Анализ больших данных - ETL реализованный с помощью Trino

## Требования

- Docker
- Docker Compose

## Запуск

```bash
docker compose up
```

## 6 Аналитических витрин

### 1. mart_sales_by_product - Витрина продаж по продуктам

**Таблица:** `mydb.mart_sales_by_product` (1000 записей)

**Поля:**
- product_id, product_name, category
- total_revenue, total_quantity, sales_count
- avg_rating, total_reviews

**Примеры запросов:**

```sql
-- Топ-10 самых продаваемых продуктов
SELECT product_name, total_revenue 
FROM mydb.mart_sales_by_product 
ORDER BY total_revenue DESC 
LIMIT 10;

-- Общая выручка по категориям продуктов
SELECT category, SUM(total_revenue) as total_revenue
FROM mydb.mart_sales_by_product 
GROUP BY category;

-- Средний рейтинг и количество отзывов для каждого продукта
SELECT product_name, avg_rating, total_reviews
FROM mydb.mart_sales_by_product
ORDER BY avg_rating DESC;
```

### 2. mart_sales_by_customer - Витрина продаж по клиентам

**Таблица:** `mydb.mart_sales_by_customer` (1000 записей)

**Поля:**
- customer_id, customer_name, country
- total_spent, orders_count, avg_order_value

**Примеры запросов:**

```sql
-- Топ-10 клиентов с наибольшей общей суммой покупок
SELECT customer_name, total_spent
FROM mydb.mart_sales_by_customer
ORDER BY total_spent DESC
LIMIT 10;

-- Распределение клиентов по странам
SELECT country, COUNT(*) as customer_count
FROM mydb.mart_sales_by_customer
GROUP BY country
ORDER BY customer_count DESC;

-- Средний чек для каждого клиента
SELECT customer_name, avg_order_value
FROM mydb.mart_sales_by_customer
ORDER BY avg_order_value DESC;
```

### 3. mart_sales_by_time - Витрина продаж по времени

**Таблица:** `mydb.mart_sales_by_time` (364 записи)

**Поля:**
- date, year, month
- total_revenue, sales_count, avg_order_amount

**Примеры запросов:**

```sql
-- Месячные тренды продаж
SELECT year, month, SUM(total_revenue) as monthly_revenue
FROM mydb.mart_sales_by_time
GROUP BY year, month
ORDER BY year, month;

-- Годовые тренды
SELECT year, SUM(total_revenue) as annual_revenue
FROM mydb.mart_sales_by_time
GROUP BY year;

-- Средний размер заказа по месяцам
SELECT month, AVG(avg_order_amount) as average_order_amount
FROM mydb.mart_sales_by_time
GROUP BY month
ORDER BY month;
```

### 4. mart_sales_by_store - Витрина продаж по магазинам

**Таблица:** `mydb.mart_sales_by_store` (383 записи)

**Поля:**
- store_name, city, country
- total_revenue, sales_count, avg_order_amount

**Примеры запросов:**

```sql
-- Топ-5 магазинов с наибольшей выручкой
SELECT store_name, total_revenue
FROM mydb.mart_sales_by_store
ORDER BY total_revenue DESC
LIMIT 5;

-- Распределение продаж по городам и странам
SELECT city, country, SUM(total_revenue) as total_revenue
FROM mydb.mart_sales_by_store
GROUP BY city, country
ORDER BY total_revenue DESC;

-- Средний чек для каждого магазина
SELECT store_name, avg_order_amount
FROM mydb.mart_sales_by_store
ORDER BY avg_order_amount DESC;
```

### 5. mart_sales_by_supplier - Витрина продаж по поставщикам

**Таблица:** `mydb.mart_sales_by_supplier` (357 записей)

**Поля:**
- supplier_name, city, country
- total_revenue, sales_count, avg_unit_price

**Примеры запросов:**

```sql
-- Топ-5 поставщиков с наибольшей выручкой
SELECT supplier_name, total_revenue
FROM mydb.mart_sales_by_supplier
ORDER BY total_revenue DESC
LIMIT 5;

-- Средняя цена товаров от каждого поставщика
SELECT supplier_name, avg_unit_price
FROM mydb.mart_sales_by_supplier
ORDER BY avg_unit_price DESC;

-- Распределение продаж по странам поставщиков
SELECT country, SUM(total_revenue) as total_revenue
FROM mydb.mart_sales_by_supplier
GROUP BY country
ORDER BY total_revenue DESC;
```

### 6. mart_product_quality - Витрина качества продукции

**Таблица:** `mydb.mart_product_quality` (1000 записей)

**Поля:**
- product_id, product_name
- avg_rating, total_reviews, total_quantity, total_revenue

**Примеры запросов:**

```sql
-- Продукты с наивысшим рейтингом
SELECT product_name, avg_rating
FROM mydb.mart_product_quality
ORDER BY avg_rating DESC
LIMIT 10;

-- Продукты с наименьшим рейтингом
SELECT product_name, avg_rating
FROM mydb.mart_product_quality
ORDER BY avg_rating ASC
LIMIT 10;

-- Корреляция между рейтингом и объемом продаж
SELECT corr(avg_rating, total_revenue) as rating_revenue_correlation
FROM mydb.mart_product_quality;

-- Продукты с наибольшим количеством отзывов
SELECT product_name, total_reviews
FROM mydb.mart_product_quality
ORDER BY total_reviews DESC
LIMIT 10;
```
