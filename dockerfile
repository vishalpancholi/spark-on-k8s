FROM apache/spark:3.5.1-scala2.12-java17-python3-ubuntu

LABEL maintainer="vishalpancholi02@gmail.com" \
      description="Spark with Delta Lake and Hive"

USER root

ARG DELTA_VERSION=3.2.1
ARG HIVE_VERSION=3.1.3
ARG MYSQL_CONNECTOR_VERSION=8.4.0
ARG HADOOP_VERSION=3.3.4

ENV SPARK_HOME="/opt/spark"
ENV HIVE_HOME="/opt/hive"
ENV PYSPARK_PYTHON=python3
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="${HADOOP_HOME}/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"


RUN apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends vim curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker/requirements/requirements.txt /opt/spark/work-dir/requirements.txt
RUN pip install --upgrade pip==24.0 && \
    pip install --no-cache-dir -r /opt/spark/work-dir/requirements.txt && \
    rm -rf /root/.cache/pip

# Install Hadoop
RUN mkdir -p ${HADOOP_HOME} && \
    wget -P /tmp https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop-${HADOOP_VERSION}.tar.gz

# Install Hive binaries FIRST
RUN mkdir -p ${HIVE_HOME} && \
    wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz -O /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzf /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt && \
    mv /opt/apache-hive-${HIVE_VERSION}-bin/* ${HIVE_HOME}/ && \
    rm /tmp/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    rmdir /opt/apache-hive-${HIVE_VERSION}-bin

# Download Spark-related JARs
RUN mkdir -p $SPARK_HOME/jars $HIVE_HOME/lib && \
    wget -P $SPARK_HOME/jars/ https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar && \
    wget -P $SPARK_HOME/jars/ https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/${DELTA_VERSION}/delta-spark_2.12-${DELTA_VERSION}.jar && \
    wget -P $HIVE_HOME/lib/ https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar

# Configure Hive (copy only once, then cp internally)
COPY docker/hive-conf/hive-site.xml ${HIVE_HOME}/conf/hive-site.xml
COPY docker/hive-conf/hive-site.xml ${SPARK_HOME}/conf/hive-site.xml

# Hive schema initialization script
COPY docker/scripts/init-hive-metastore.sh /init-hive-metastore.sh
RUN chmod +x /init-hive-metastore.sh

WORKDIR /opt/spark/work-dir

# The default CMD will be whatever the base Spark image provides (e.g., bash or a Spark entrypoint)