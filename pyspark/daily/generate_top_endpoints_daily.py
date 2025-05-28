from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, to_date, lit
import argparse
import sys
from datetime import datetime

def generate_top_endpoints_daily(process_date: str, input_path: str, output_path: str):
    spark = SparkSession.builder \
        .appName(f"TopEndpointsDaily_for_{process_date}_Overwrite") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .getOrCreate()

    spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")

    print(f"Input path: {input_path}")
    print(f"Output path: {output_path}")
    print(f"Process date: {process_date}")

    df_processed = spark.read.format("delta").load(input_path) \
        .filter(to_date(col("process_time")) == to_date(lit(process_date)))

    df_top = df_processed \
        .withColumn("log_time", to_date(col("log_time"))) \
        .groupBy(to_date(col("process_time")).alias("process_time"), col("log_time"), col("endpoint")) \
        .agg(count("*").alias("count")) \
        .select("process_time", "log_time", "endpoint", "count")

    df_top.write \
        .format("delta") \
        .mode("overwrite") \
        .option("replaceWhere", f"process_time = '{process_date}'") \
        .save(output_path)

    result_count = spark.read.format("delta").load(output_path) \
        .filter(col("process_time") == to_date(lit(process_date))) \
        .count()

    print(f"Verification: {result_count} records written for {process_date}")
    spark.stop()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--process_date", "-d", required=True)
    parser.add_argument("--input_path", "-i", required=True)
    parser.add_argument("--output_path", "-o", required=True)
    args = parser.parse_args()

    try:
        datetime.strptime(args.process_date, '%Y-%m-%d')
    except ValueError:
        print(f"ERROR: Invalid date format '{args.process_date}'.")
        sys.exit(1)

    generate_top_endpoints_daily(args.process_date, args.input_path, args.output_path)