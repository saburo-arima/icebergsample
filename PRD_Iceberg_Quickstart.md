## PRD：Iceberg Quickstart Demo

*ver 0.9 — 2025-05-06*

---

### 1. 背景 / Why now?

* HULFT Square・DataSpider・HULFT10 開発チーム内で Iceberg を触ったことがないメンバーが多い
* 「実物を一度動かす」ことでフォーマットの利点（スキーマ進化・ACID・高速リード）を肌感で理解したい
* 完全にローカルで動くサンプルがあれば、各プロダクトへの PoC 連携もすぐ試せる

### 2. ゴール

* **30 分以内**に誰でも Iceberg テーブル作成 → データ投入 → クエリ実行まで完走できる
* HULFT 系ワークフローとの“つなぎ代”がイメージできる

### 3. KPI / 成功指標

| 指標                           | 目標値    |
| ---------------------------- | ------ |
| セットアップ完了までの平均時間              | ≤ 15 分 |
| デモ完走率（README を最後まで実行できた割合）   | ≥ 90 % |
| PRD 公開から 1 週間で社内スター数（GitHub） | ≥ 15   |

### 4. 想定ユーザー

* **社内データエンジニア／ジュニア開発者**
* Docker が動かせる PC があれば OK

### 5. ユースケース（最小構成）

> **UC-01：CSV ログを Iceberg にロードして集計する**
>
> 1. ユーザーが NYC Taxi CSV（約 20 MB）を `/data` に配置
> 2. `make up` で Docker Compose 起動（Spark + HadoopCatalog）
> 3. Spark-SQL で `CREATE TABLE` & `COPY INTO` 実行
> 4. SQL で日別売上を集計 → 画面に結果を確認
> 5. スキーマに `payment_type` 列を `ALTER TABLE ADD COLUMN` で追加
> 6. 追加後も過去データが壊れていないことを SELECT で確認

### 6. 機能要件

| ID   | 要件                                                                       |
| ---- | ------------------------------------------------------------------------ |
| F-01 | `docker compose up` だけで Spark 3.5 + Iceberg 1.8.1 + HadoopCatalog が立ち上がる |
| F-02 | `make demo` で UC-01 の一連コマンドを半自動実行（シェル or Python）                         |
| F-03 | README に HULFT10（ファイル転送）→ `warehouse/` 連携例を一段落で記載                        |
| F-04 | テーブルスキーマ変更（ADD COLUMN）後も旧データが読めることを自動テストで検証                              |

### 7. 非機能要件

| ID   | 要件                                                    |
| ---- | ----------------------------------------------------- |
| N-01 | ローカルメモリ消費 4 GB 以内、ディスク 3 GB 以内                        |
| N-02 | Windows／macOS 両対応（Docker Desktop 前提）                  |
| N-03 | セットアップは 3 コマンド以内（`git clone`, `make up`, `make demo`） |
| N-04 | README は日本語／英語併記、所要 5 分で読破できるボリューム                    |

### 8. UI / UX

* UI は Spark-SQL CLI だけ。
* 成功パスでは緑色の ASCII アートで “🎉 DONE” を出す程度。

### 9. アウト・オブ・スコープ

* AWS Glue カタログ連携
* 本番向け権限管理・暗号化
* Scala/Java API の深堀り実装（README にリンクのみ）

### 10. マイルストーン

| 期日    | マイルストーン                          |
| ----- | -------------------------------- |
| 05-08 | Docker Compose 定義完成・動作確認         |
| 05-10 | `make demo` スクリプト & 自動テスト整備      |
| 05-12 | README / チュートリアル草稿レビュー           |
| 05-15 | 社内公開（GitHub Enterprise）& ユーザーテスト |
| 05-20 | フィードバック反映 & v1.0 リリース            |

### 11. リスク / 対策

| リスク                         | インパクト | 対策                                      |
| --------------------------- | ----- | --------------------------------------- |
| Docker 不慣れなメンバーが詰まる         | 中     | GIF 付きセットアップ動画を README に埋め込む            |
| M1/M2 Mac の ARM イメージ互換      | 低     | Iceberg 公式イメージは multi-arch 対応済み、動作確認を先行 |
| Spark 3.5 と Iceberg 最新の依存競合 | 中     | 公式 Quickstart の BOM をそのまま採用、CI で毎週ビルド   |

### 12. 参考リンク

* Apache Iceberg Quickstart Docs
* 社内 HULFT10 → Iceberg PoC メモ（Confluence）

---

“動くもの”が最強。これでまず触って、次は DataSpider から直接 Iceberg Writer 呼び出しを試そう。
