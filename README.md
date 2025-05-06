# Iceberg Quickstart Demo

## 概要 / Overview

このリポジトリはApache Icebergを30分以内に試せるクイックスタートデモです。DockerとMakeを使って、ローカルでIcebergテーブルを作成し、データ操作とクエリを実行できます。

This repository provides a quickstart demo for Apache Iceberg that can be completed within 30 minutes. Using Docker and Make, you can create Iceberg tables, manipulate data, and run queries locally.

## 前提条件 / Prerequisites

- Docker Desktop (Windows/macOS)
- Make（オプション、なくてもコマンドを個別に実行可能）

## クイックスタート / Quick Start

```bash
# 1. リポジトリをクローン
git clone https://github.com/yourusername/iceberg-quickstart-demo.git
cd iceberg-quickstart-demo

# 2. 環境を起動（Spark 3.5 + Iceberg 1.8.1 + HadoopCatalog）
make up
# または: docker compose up -d

# 3. デモを実行（NYC Taxiデータのロードと分析）
make demo
# または: ./scripts/run_demo.sh
```

## デモ内容 / Demo Contents

このデモでは以下の操作を体験できます：

1. NYC Taxi CSVデータをIcebergテーブルにロード
2. 日別売上の集計クエリを実行
3. スキーマ進化機能を使って列を追加
4. 追加後も過去データが問題なく読み取れることを確認

The demo includes the following operations:

1. Loading NYC Taxi CSV data into an Iceberg table
2. Running aggregation queries for daily revenue
3. Adding columns using schema evolution
4. Verifying that historical data remains accessible after schema changes

## 他システムとの連携 / Integration with Other Systems

### HULFT10との連携例

HULFT10を使ってファイルを`warehouse/`ディレクトリに転送するだけで、Icebergテーブルのデータとして利用できます。以下は設定例です：

```
送信元: 業務サーバー
送信先: ${DEMO_DIR}/warehouse/nyc_taxi/
ファイル形式: CSV
転送後処理: なし（Icebergが自動的に新規ファイルを検出）
```

## リソース要件 / Resource Requirements

- メモリ: 4GB以下
- ディスク: 3GB以下

## 参考リンク / References

- [Apache Iceberg 公式ドキュメント](https://iceberg.apache.org/docs/latest/)
- [Spark SQL ドキュメント](https://spark.apache.org/docs/latest/sql-programming-guide.html) 