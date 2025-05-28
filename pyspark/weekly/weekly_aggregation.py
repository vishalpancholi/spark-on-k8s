from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum as _sum, lit
from datetime import datetime, timedelta
import argparse

def generate_weekly_rollup(process_date_str, input_path, output_path, group_cols):
    spark = SparkSession.builder \
        .appName(f"WeeklyRollup_{process_date_str}") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .getOrCreate()

    spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic")

    process_date = datetime.strptime(process_date_str, "%Y-%m-%d")
    start_date = process_date - timedelta(days=6)  # Last 7 days including process_date
    end_date = process_date

    print(f"Rolling up data from {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")

    # Read input delta table and filter last 7 days by log_time
    df = spark.read.format("delta").load(input_path) \
        .filter((col("log_time") >= lit(start_date.strftime('%Y-%m-%d'))) &
                (col("log_time") <= lit(end_date.strftime('%Y-%m-%d'))))

    group_cols_list = [c.strip() for c in group_cols.split(",")]

    # Group by the specified columns (not including log_time) and aggregate
    df_agg = df.groupBy(*group_cols_list).agg(_sum("count").alias("count"))

    # Add process_time and set log_time to the process_date (single rollup date)
    df_result = df_agg \
        .withColumn("process_time", lit(process_date_str).cast("date")) \
        .withColumn("log_time", lit(process_date_str).cast("date"))

    # Final column order
    final_cols = ["process_time", "log_time"] + group_cols_list + ["count"]
    df_result = df_result.select(*final_cols)

    # Write with partition overwrite - this will replace any existing data
    df_result.write.format("delta").mode("overwrite") \
        .option("replaceWhere", f"process_time = date'{process_date_str}'") \
        .save(output_path)

    print(f"Weekly rollup for {process_date_str} written to {output_path}")

    # Show what was written
    print("Sample of written data:")
    df_result.show(5)

    spark.stop()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--process_date", "-d", required=True, help="Process date in YYYY-MM-DD format")
    parser.add_argument("--input_path", "-i", required=True, help="Input Delta table path")
    parser.add_argument("--output_path", "-o", required=True, help="Output Delta table path")
    parser.add_argument("--group_cols", "-g", required=True, help="Comma-separated grouping columns")
    args = parser.parse_args()

    generate_weekly_rollup(args.process_date, args.input_path, args.output_path, args.group_cols)