#!/bin/bash
set -e

until clickhouse-client --user meow --password UwU --query "SELECT 1" >/dev/null 2>&1; do
  echo "Waiting for ClickHouse..."
  sleep 2
done

echo "ClickHouse is ready. Initializing database..."

clickhouse-client --user meow --password UwU --multiquery <<'EOF'
CREATE DATABASE IF NOT EXISTS mydb;

USE mydb;

CREATE TABLE IF NOT EXISTS sales (
    id UInt32,
    customer_first_name String,
    customer_last_name String,
    customer_age UInt8,
    customer_email String,
    customer_country String,
    customer_postal_code String,
    customer_pet_type String,
    customer_pet_name String,
    customer_pet_breed String,
    seller_first_name String,
    seller_last_name String,
    seller_email String,
    seller_country String,
    seller_postal_code String,
    product_name String,
    product_category String,
    product_price Decimal(10,2),
    product_quantity UInt32,
    sale_date String,
    sale_customer_id UInt32,
    sale_seller_id UInt32,
    sale_product_id UInt32,
    sale_quantity UInt32,
    sale_total_price Decimal(10,2),
    store_name String,
    store_location String,
    store_city String,
    store_state String,
    store_country String,
    store_phone String,
    store_email String,
    pet_category String,
    product_weight Decimal(10,2),
    product_color String,
    product_size String,
    product_brand String,
    product_material String,
    product_description String,
    product_rating Decimal(3,1),
    product_reviews UInt32,
    product_release_date String,
    product_expiry_date String,
    supplier_name String,
    supplier_contact String,
    supplier_email String,
    supplier_phone String,
    supplier_address String,
    supplier_city String,
    supplier_country String
) ENGINE = MergeTree()
ORDER BY id;
EOF

echo "Importing CSV files..."
for i in 0 1 2 3 4; do
  echo "Importing MOCK_DATA ($i).csv..."
  clickhouse-client --user meow --password UwU \
    --query "INSERT INTO mydb.sales FORMAT CSVWithNames" \
    < "/var/lib/clickhouse/source_data/MOCK_DATA ($i).csv"
done

echo "ClickHouse initialization completed!"