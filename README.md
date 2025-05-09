# Iceberg Quickstart Demo

## 概要 / Overview

このリポジトリはApache Icebergを30分以内に試せるクイックスタートデモです。DockerとMakeを使って、ローカルでIcebergテーブルを作成し、データ操作とクエリを実行できます。

This repository provides a quickstart demo for Apache Iceberg that can be completed within 30 minutes. Using Docker and Make, you can create Iceberg tables, manipulate data, and run queries locally.

## 前提条件 / Prerequisites

- Docker Desktop (Windows/macOS) (企業利用の場合は有償プランを必ずご利用ください）
- Make（オプション、なくてもコマンドを個別に実行可能）
- 約3GBのディスク容量
- メモリ4GB以上（Dockerに割り当て）

## クイックスタート / Quick Start

```bash
# 1. リポジトリをクローン
git clone https://github.com/saburo-arima/iceberg-quickstart-demo.git
cd iceberg-quickstart-demo

# 2. 環境を構築して起動（Spark 3.5.0 + Iceberg 1.4.3）
make rebuild

# 3. デモを実行（NYC Taxiデータのロードと分析）
make demo
```

問題が発生した場合は、`make clean`でクリーンアップしてから再度お試しください。

## デモ内容 / Demo Contents

このデモでは以下の操作を体験できます：

1. NYC Taxi Parquetデータをダウンロードしてローカルに保存
2. Icebergテーブルを作成し、データをロード（INSERT INTO）
3. 日別売上の集計クエリを実行
4. スキーマ進化機能を使って`payment_type`列を追加
5. 追加後も過去データが問題なく読み取れることを確認

The demo includes the following operations:

1. Downloading NYC Taxi Parquet data to local storage
2. Creating an Iceberg table and loading data (INSERT INTO)
3. Running aggregation queries for daily revenue
4. Adding columns using schema evolution
5. Verifying that historical data remains accessible after schema changes

## コマンド一覧 / Available Commands

| コマンド | 説明 |
|---------|------|
| `make up` | Dockerコンテナを起動 |
| `make down` | Dockerコンテナを停止 |
| `make rebuild` | 環境を完全にクリーンアップして再構築 |
| `make demo` | デモを実行（データのダウンロードと分析） |
| `make clean` | 全てのデータとコンテナをクリーンアップ |

## 技術スタック / Tech Stack

- Apache Spark 3.5.0
- Apache Iceberg 1.4.3
- Docker & Docker Compose
- NYC Taxi Dataset (2019-01, Parquet形式)

## 他システムとの連携 / Integration with Other Systems

### HULFT10との連携例

HULFT10を使ってファイルを`warehouse/`ディレクトリに転送するだけで、Icebergテーブルのデータとして利用できます。以下は設定例です：

```
送信元: 業務サーバー
送信先: ${DEMO_DIR}/warehouse/db.db/nyc_taxi/
ファイル形式: Parquet
転送後処理: なし（Icebergが自動的に新規ファイルを検出）
```

### DataSpiderとの連携

DataSpiderからJDBCコネクタを使用して、Sparkの`thrift://localhost:10000`エンドポイントに接続することで、Icebergテーブルに対してSQLクエリを実行できます。(現時点ではサービスを上げていないので利用不可）

## トラブルシューティング / Troubleshooting

- **Docker関連のエラー**: Docker Desktopが起動していることを確認してください
- **メモリ不足エラー**: Docker Desktopの設定でメモリ割り当てを増やしてください（4GB以上推奨）
- **SQLエラー**: スキーマの互換性を確認してください。Parquetファイルのスキーマと作成するテーブルのスキーマが一致している必要があります

## 参考リンク / References

- [Apache Iceberg 公式ドキュメント](https://iceberg.apache.org/docs/latest/)
- [Spark SQL ドキュメント](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [NYC Taxi & Limousine Commission データセット](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) 



## 起動構成
このプロジェクトは単一のDockerコンテナをベースとしたシンプルな構成で動作しています。

### サーバー側コンポーネント
1. **Apache Sparkサーバー**:
   - `apache/spark:3.5.0` イメージをベースにしたコンテナ
   - SparkマスターがUI用に8080ポートで動作
   - Spark Jobモニタリング用に4040ポートで動作
   - コンテナ名: `iceberg-demo-spark`

2. **Apache Icebergライブラリ**:
   - Sparkに統合されたIcebergライブラリ（JARファイル）
   - 設定ファイルで定義されたIcebergカタログ
   - データ格納場所: `/opt/spark/warehouse`（コンテナ内）

### クライアント側コンポーネント
1. **コマンドラインインターフェース**:
   - Makefileを使用したコマンド実行
   - `make up`, `make demo`, `make test` などの操作

2. **Webインターフェース**:
   - SparkマスターUI: `http://localhost:8080`
   - SparkジョブUI: `http://localhost:4040`（ジョブ実行時のみ）

### 全体的なアーキテクチャ
```
[ローカルマシン] <------- HTTP(8080/4040) -------> [Dockerコンテナ]
     ↓                                                  ↓
[make コマンド] ----> [docker exec] ---> [Sparkコンテナ内のコマンド]
     ↓                                                  ↓
[ローカルファイル] <-- ボリュームマウント --> [コンテナ内ファイル]
  ./warehouse/                             /opt/spark/warehouse/
  ./data/                                  /opt/spark/data/
  ./scripts/                               /opt/spark/scripts/
```

### 接続方法
- **Spark SQL**: `docker exec -it iceberg-demo-spark /opt/spark/bin/spark-sql` で直接Spark SQLクライアントに接続
- **Web UI**: ブラウザから `http://localhost:8080` でSparkマスターUIにアクセス
- **外部ツール**: Makefile定義のコマンドを使用して操作（`make demo`等）

基本的には単一のコンテナ内で完結する自己完結型のデモ環境であり、複数のサーバーが連携する分散システムではありません。ユーザーが使いやすく、単一環境で素早くIcebergの機能を試せるように設計されています。
