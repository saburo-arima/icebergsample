.PHONY: up down demo download-data clean rebuild

# デフォルトゴール
all: up demo

# Docker環境を起動
up:
	@echo "🚀 Sparkコンテナを起動しています..."
	@mkdir -p warehouse data spark-events jars
	@docker compose up -d
	@echo "✅ 起動完了 - Spark UI: http://localhost:8080"

# Docker環境を停止
down:
	@echo "🛑 コンテナを停止しています..."
	@docker compose down
	@echo "✅ 停止完了"

# 完全リビルド
rebuild:
	@echo "🔄 環境を再構築しています..."
	@docker compose down -v
	@docker compose build --no-cache
	@docker compose up -d
	@echo "✅ 再構築完了"

# NYCタクシーデータをダウンロード (約20MB)
download-data:
	@echo "📥 NYCタクシーデータをダウンロードしています..."
	@mkdir -p data
	@curl -o data/nyc_taxi_sample.parquet -L https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2019-01.parquet
	@echo "✅ ダウンロード完了"

# デモを実行
demo: download-data
	@echo "🧪 Icebergデモを実行しています..."
	@chmod +x scripts/demo.sh
	@docker exec -it iceberg-demo-spark /opt/spark/scripts/demo.sh
	@echo ""
	@echo "🎉 デモ完了! - Spark UI: http://localhost:8080"

# テストを実行
test:
	@echo "🧪 テストを実行しています..."
	@chmod +x scripts/run_tests.sh
	@docker exec -it iceberg-demo-spark /opt/spark/scripts/run_tests.sh

# クリーンアップ
clean:
	@echo "🧹 クリーンアップしています..."
	@docker compose down -v
	@rm -rf warehouse/* data/nyc_taxi_sample.parquet spark-events/*
	@echo "✅ クリーンアップ完了" 