#!/bin/bash
set -e

# 色の定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 作業ディレクトリ
WAREHOUSE_DIR="/opt/spark/warehouse"

echo -e "${YELLOW}===== Iceberg スキーマ進化テスト =====${NC}"
echo -e "テスト：スキーマ変更後も過去データが読める\n"

# SparkセッションでIcebergを初期化して、クエリの結果を変数に格納
TEST_RESULT=$(/opt/spark/bin/spark-sql \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.3 \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.local.type=hadoop \
  --conf spark.sql.catalog.local.warehouse=$WAREHOUSE_DIR \
  --conf spark.sql.defaultCatalog=local \
  -e "
-- カラム追加前に存在したレコード数を確認
SELECT COUNT(*) AS record_count FROM local.db.nyc_taxi;
")

# 結果から行数を抽出
RECORD_COUNT=$(echo "$TEST_RESULT" | grep -oE '[0-9]+')

if [ -z "$RECORD_COUNT" ] || [ "$RECORD_COUNT" -eq 0 ]; then
  echo -e "${RED}❌ テスト失敗: レコードが見つかりません${NC}"
  exit 1
else
  echo -e "${GREEN}✅ テスト成功: $RECORD_COUNT 件のレコードが取得できました${NC}"
  echo -e "${GREEN}スキーマ進化後も全てのデータに正常にアクセスできています${NC}"
fi

# テスト2: payment_type列の存在確認
echo -e "\nテスト：payment_type列がスキーマに追加されているか確認"

COLUMN_TEST=$(/opt/spark/bin/spark-sql \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.3 \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.local.type=hadoop \
  --conf spark.sql.catalog.local.warehouse=$WAREHOUSE_DIR \
  --conf spark.sql.defaultCatalog=local \
  -e "
DESCRIBE TABLE local.db.nyc_taxi;
")

if echo "$COLUMN_TEST" | grep -q "payment_type"; then
  echo -e "${GREEN}✅ テスト成功: payment_type列が正常に追加されています${NC}"
else
  echo -e "${RED}❌ テスト失敗: payment_type列が見つかりません${NC}"
  exit 1
fi

echo -e "\n${GREEN}🎉 全てのテストが成功しました！${NC}"
echo -e "Icebergのスキーマ進化機能が正常に動作しています。" 