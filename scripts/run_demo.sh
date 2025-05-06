#!/bin/bash
set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 作業ディレクトリ
WAREHOUSE_DIR="/opt/spark/warehouse"
DATA_DIR="/opt/spark/data"

echo -e "${YELLOW}===== Iceberg クイックスタートデモ =====${NC}"
echo -e "${BLUE}このデモでは、Icebergテーブルの作成、データのロード、クエリ実行、スキーマ進化を体験できます。${NC}"
echo ""

# ディレクトリがなければ作成
mkdir -p $WAREHOUSE_DIR/db.db

# 1. Spark SQL CLIを起動
echo -e "${YELLOW}1. Spark SQLの設定を行っています...${NC}"

# SparkセッションでIcebergを初期化する
/opt/spark/bin/spark-sql -v \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.3 \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.local.type=hadoop \
  --conf spark.sql.catalog.local.warehouse=$WAREHOUSE_DIR \
  --conf spark.sql.defaultCatalog=local \
  -e "
-- 2. Icebergテーブルの作成
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

-- 3. データのロード (Parquet)
COPY INTO local.db.nyc_taxi
FROM '$DATA_DIR/nyc_taxi_sample.parquet'
FILEFORMAT = PARQUET;

-- 4. テーブル情報の表示
DESCRIBE TABLE EXTENDED local.db.nyc_taxi;

-- 5. データ集計クエリの実行
SELECT 
  date_format(pickup_datetime, 'yyyy-MM-dd') as trip_date,
  count(*) as trip_count,
  sum(total_amount) as total_revenue
FROM local.db.nyc_taxi
GROUP BY date_format(pickup_datetime, 'yyyy-MM-dd')
ORDER BY trip_date;

-- 6. スキーマ進化（payment_type列の追加）
ALTER TABLE local.db.nyc_taxi ADD COLUMN payment_type STRING;

-- 7. 変更後のスキーマ確認
DESCRIBE TABLE local.db.nyc_taxi;

-- 8. 変更後もデータが読めることを確認
SELECT
  date_format(pickup_datetime, 'yyyy-MM-dd') as trip_date,
  count(*) as trip_count,
  sum(total_amount) as total_revenue,
  count(payment_type) as payment_type_count
FROM local.db.nyc_taxi
GROUP BY date_format(pickup_datetime, 'yyyy-MM-dd')
ORDER BY trip_date;
"

echo ""
echo -e "${GREEN}🎉 おめでとうございます！Icebergクイックスタートデモが完了しました🎉${NC}"
echo -e "${BLUE}  - ✅ テーブル作成とデータロード${NC}"
echo -e "${BLUE}  - ✅ クエリ実行と集計${NC}"
echo -e "${BLUE}  - ✅ スキーマ進化（列の追加）${NC}"
echo -e "${BLUE}  - ✅ 変更後も過去データが読み取り可能${NC}"
echo ""
echo -e "${YELLOW}次のステップ:${NC}"
echo -e "  - 'make test' でスキーマ変更後のデータ整合性テストを実行"
echo -e "  - 'make down' で環境を停止"
echo -e "  - README.mdで他システムとの連携方法を確認" 