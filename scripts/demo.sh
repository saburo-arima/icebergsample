#!/bin/bash
set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== Iceberg クイックスタートデモ =====${NC}"
echo -e "${BLUE}このデモでは、Icebergテーブルの作成、データのロード、クエリ実行、スキーマ進化を体験できます。${NC}"
echo ""

# 1. Spark SQL CLIを起動
echo -e "${YELLOW}1. Spark SQLでクエリを実行しています...${NC}"

# SQLファイルを実行
cd /opt/spark
cat /opt/spark/scripts/run_demo.sql | /opt/spark/bin/spark-sql \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
  --conf spark.sql.catalog.spark_catalog.type=hive \
  --conf spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.local.type=hadoop \
  --conf spark.sql.catalog.local.warehouse=/opt/spark/warehouse \
  --conf spark.sql.defaultCatalog=local

echo ""
echo -e "${GREEN}🎉 おめでとうございます！Icebergクイックスタートデモが完了しました🎉${NC}"
echo -e "${BLUE}  - ✅ テーブル作成とデータロード${NC}"
echo -e "${BLUE}  - ✅ クエリ実行と集計${NC}"
echo -e "${BLUE}  - ✅ スキーマ進化（列の追加）${NC}"
echo -e "${BLUE}  - ✅ 変更後も過去データが読み取り可能${NC}"
echo "" 