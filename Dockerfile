FROM apache/spark:3.5.0

USER root

# Icebergの依存関係をインストール
RUN cd /opt && \
    wget -q https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.4.3/iceberg-spark-runtime-3.5_2.12-1.4.3.jar -P /opt/spark/jars/ && \
    wget -q https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar -P /opt/spark/jars/ && \
    wget -q https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.20.18/bundle-2.20.18.jar -P /opt/spark/jars/ && \
    mkdir -p /opt/spark/warehouse

# 作業ディレクトリ
WORKDIR /opt/spark

# sparkユーザーに戻す
USER spark

# デモ用のディレクトリ
RUN mkdir -p /opt/spark/warehouse /opt/spark/data 