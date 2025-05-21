FROM apache/spark:3.5.1-scala2.12-java17-python3-ubuntu

USER root

# working directory
WORKDIR /opt/spark/work-dir

# Install system dependencies
RUN apt-get -qq update && \
    apt-get -qq -y install vim curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# environment variables
ENV DELTA_VERSION=3.2.1
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"
ENV PYSPARK_PYTHON=python3

# Install Python dependencies
COPY requirements.txt /opt/spark/work-dir/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /opt/spark/work-dir/requirements.txt && \
    rm -f /opt/spark/work-dir/requirements.txt

# Download Delta Lake JARs

RUN wget -P /opt/spark/jars/ https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar && \
    wget -P /opt/spark/jars/ https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/${DELTA_VERSION}/delta-spark_2.12-${DELTA_VERSION}.jar

# Set default command
CMD ["bash"]
