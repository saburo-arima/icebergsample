-- 1. Icebergテーブルの作成
DROP TABLE IF EXISTS local.db.nyc_taxi;

CREATE TABLE local.db.nyc_taxi (
  vendor_id STRING,
  pickup_datetime TIMESTAMP,
  dropoff_datetime TIMESTAMP,
  passenger_count INT,
  trip_distance FLOAT,
  fare_amount FLOAT,
  tip_amount FLOAT,
  total_amount FLOAT
) USING iceberg
PARTITIONED BY (days(pickup_datetime));

-- 2. データのロード (Parquet)
COPY INTO local.db.nyc_taxi
FROM '/opt/spark/data/nyc_taxi_sample.parquet'
FILEFORMAT = PARQUET;

-- 3. テーブル情報の表示
DESCRIBE TABLE EXTENDED local.db.nyc_taxi;

-- 4. データ集計クエリの実行
SELECT 
  date_format(pickup_datetime, 'yyyy-MM-dd') as trip_date,
  count(*) as trip_count,
  sum(total_amount) as total_revenue
FROM local.db.nyc_taxi
GROUP BY date_format(pickup_datetime, 'yyyy-MM-dd')
ORDER BY trip_date;

-- 5. スキーマ進化（payment_type列の追加）
ALTER TABLE local.db.nyc_taxi ADD COLUMN payment_type STRING;

-- 6. 変更後のスキーマ確認
DESCRIBE TABLE local.db.nyc_taxi;

-- 7. 変更後もデータが読めることを確認
SELECT
  date_format(pickup_datetime, 'yyyy-MM-dd') as trip_date,
  count(*) as trip_count,
  sum(total_amount) as total_revenue,
  count(payment_type) as payment_type_count
FROM local.db.nyc_taxi
GROUP BY date_format(pickup_datetime, 'yyyy-MM-dd')
ORDER BY trip_date; 