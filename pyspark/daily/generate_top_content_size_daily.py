from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, to_date, lit
import argparse, sys
from datetime import datetime

def generate_top_content_size_daily(process_date, input_path, output_path):
    spark = SparkSession.builder \
        .appName(f"TopContentSizeDaily_for_{process_date}") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .getOrCreate()

    spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")

    df = spark.read.format("delta").load(input_path).filter(to_date("process_time") == process_date)

    df_result = df.withColumn("log_time", to_date("log_time")) \
        .groupBy(to_date("process_time").alias("process_time"), "log_time", "content_size") \
        .agg(count("*").alias("count"))

    df_result.write.format("delta").mode("overwrite") \
        .option("replaceWhere", f"process_time = '{process_date}'").save(output_path)

    print(f"Generated top_content_size_daily for {process_date}")
    spark.stop()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--process_date", "-d", required=True)
    parser.add_argument("--input_path", "-i", required=True)
    parser.add_argument("--output_path", "-o", required=True)
    args = parser.parse_args()

    generate_top_content_size_daily(args.process_date, args.input_path, args.output_path)