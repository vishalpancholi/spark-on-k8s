FROM apache/spark:3.5.1-scala2.12-java17-python3-ubuntu

LABEL maintainer="vishalpancholi02@gmail.com" \
      description="Spark with Delta Lake and Hive"

USER root

ENV SPARK_HOME="/opt/spark"
ENV PYSPARK_PYTHON=python3
ARG HIVE_VERSION=3.1.3
ENV HIVE_HOME="/opt/hive"
ENV PATH="$HIVE_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

# Pre-downloaded JARs for faster and repeatable Docker builds
COPY docker/jars/*.jar /opt/spark/jars/
RUN rm  -rf /opt/spark/jars/hadoop*3.3.4.jar

RUN apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends vim curl wget mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker/requirements/requirements.txt /tmp/requirements.txt
COPY docker/hive-conf/hive-site.xml ${SPARK_HOME}/conf/hive-site.xml
COPY docker/hive-conf/hive-site.xml ${HIVE_HOME}/conf/hive-site.xml

RUN pip install -r /tmp/requirements.txt

WORKDIR /opt/spark/work-dir