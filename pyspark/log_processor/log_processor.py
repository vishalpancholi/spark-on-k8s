import logging
import argparse
import sys
import time
from datetime import datetime
from pyspark.sql import SparkSession
from pyspark.sql.functions import regexp_extract, col, to_date, lit, when
from pyspark.sql.types import StructType, StructField, StringType, BooleanType, LongType, IntegerType
from user_agents import parse as ua_parse
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

OUTPUT_TABLE = "processed_data"
LOG_PATTERN = r'(\S+) - - \[(.*?)\] "(.*?) (.*?) (.*?)" (\d{3}) (\d+|-) ".*?" "(.*?)"'

# Prometheus Pushgateway settings
PUSHGATEWAY_URL = "prometheus-pushgateway.monitoring.svc.cluster.local:9091"
JOB_NAME = "apache_log_processor" # Unique identifier for your Spark job's metrics

# Functions

def setup_logging(process_date):
    """Configure logging with job identification"""
    logger = logging.getLogger(f'apache_log_processor_{process_date}')
    logger.setLevel(logging.INFO)

    formatter = logging.Formatter(
        f'%(asctime)s - apache_log_processor_{process_date} - %(levelname)s - %(message)s'
    )

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    if not logger.handlers:
        logger.addHandler(console_handler)

    return logger

def get_spark_session():
    """Get existing SparkSession from spark-submit"""
    return SparkSession.getActiveSession() or SparkSession.builder.getOrCreate()

def parse_arguments():
    """Parse command line arguments for spark-submit"""
    parser = argparse.ArgumentParser(
        description="Process Apache log files with PySpark",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--process_date",
        required=True,
        help="Process date in YYYY-MM-DD format. Example: 2025-04-01"
    )

    return parser.parse_args()

def validate_arguments_and_build_path(args):
    """Validate command line arguments and build input path"""
    try:
        process_date = datetime.strptime(args.process_date, "%Y-%m-%d").date()
        input_path = f"abfss://raw@granicasa.dfs.core.windows.net/data/{args.process_date}/part*.txt"
        return process_date, input_path
    except ValueError as e:
        print(f"Invalid arguments: {e}")
        sys.exit(1)

# Optimized User Agent parsing
def parse_ua_optimized(ua_str):
    if not ua_str or ua_str == "-":
        return ("Unknown", "Unknown", "Unknown", "Unknown", "Unknown", False, False, False, False)

    try:
        ua = ua_parse(ua_str)
        return (
            ua.browser.family or "Unknown",
            ua.browser.version_string or "Unknown",
            ua.os.family or "Unknown",
            ua.os.version_string or "Unknown",
            ua.device.family or "Unknown",
            bool(ua.is_mobile),
            bool(ua.is_tablet),
            bool(ua.is_pc),
            bool(ua.is_bot)
        )
    except Exception:
        # Fallback for parsing errors
        return ("Unknown", "Unknown", "Unknown", "Unknown", "Unknown", False, False, False, False)

def create_ua_broadcast_lookup(spark, df, logger):
    """Create broadcast lookup table for user agents"""
    logger.info("Creating user agent lookup table")
    unique_uas = df.select("user_agent").distinct().collect()

    ua_lookup = {}
    for row in unique_uas:
        ua_str = row.user_agent
        ua_lookup[ua_str] = parse_ua_optimized(ua_str)

    broadcast_lookup = spark.sparkContext.broadcast(ua_lookup)
    logger.info(f"Broadcast lookup table created ({len(ua_lookup):,} entries)")
    return broadcast_lookup

ua_schema = StructType([
    StructField("browser", StringType()),
    StructField("browser_version", StringType()),
    StructField("os", StringType()),
    StructField("os_version", StringType()),
    StructField("device_type", StringType()),
    StructField("is_mobile", BooleanType()),
    StructField("is_tablet", BooleanType()),
    StructField("is_pc", BooleanType()),
    StructField("is_bot", BooleanType())
])

# Schema definition for user agent parsing UDF
def register_ua_lookup_udf(spark, broadcast_lookup):
    """Register broadcast lookup UDF"""
    def lookup_ua(ua_string):
        return broadcast_lookup.value.get(
            ua_string,
            ("Unknown", "Unknown", "Unknown", "Unknown", "Unknown", False, False, False, False)
        )
    return spark.udf.register("lookup_ua_udf", lookup_ua, ua_schema)

def process_apache_logs(spark, input_path, process_date, output_table, logger):
    """Main processing function with custom Prometheus metric pushing"""

    # --- Prometheus Metrics Setup ---
    # Create a registry for this job's metrics
    registry = CollectorRegistry()

    # Define Gauges for your custom metrics. Gauges can go up and down.
    # The 'process_date' label allows you to filter metrics by date in Prometheus.
    logs_processed_metric = Gauge(
        'spark_apache_logs_processed_total',
        'Total number of Apache log entries processed.',
        ['process_date'],
        registry=registry
    )
    bot_ips_metric = Gauge(
        'spark_apache_bot_ips_count',
        'Number of unique bot IPs identified.',
        ['process_date'],
        registry=registry
    )
    job_duration_seconds_metric = Gauge(
        'spark_apache_job_duration_seconds',
        'Duration of the Apache log processing job in seconds.',
        ['process_date'],
        registry=registry
    )
    job_status_metric = Gauge(
        'spark_apache_job_status',
        'Status of the Apache log processing job (0=failed, 1=succeeded).',
        ['process_date'],
        registry=registry
    )

    # Define labels for all metrics (e.g., the specific process date)
    metric_labels = {'process_date': process_date.strftime('%Y-%m-%d')}

    job_start_time = time.time()

    try:
        logger.info(f"Reading raw log files from: {input_path}")
        raw_df = spark.read.text(input_path)
        raw_df.cache()

        # Parse logs
        parsed_df = raw_df.select(
            regexp_extract("value", LOG_PATTERN, 1).alias("ip"),
            regexp_extract("value", LOG_PATTERN, 2).alias("timestamp"),
            regexp_extract("value", LOG_PATTERN, 3).alias("method"),
            regexp_extract("value", LOG_PATTERN, 4).alias("endpoint"),
            regexp_extract("value", LOG_PATTERN, 5).alias("protocol"),
            regexp_extract("value", LOG_PATTERN, 6).cast("int").alias("status"),
            regexp_extract("value", LOG_PATTERN, 7).alias("content_size_raw"),
            regexp_extract("value", LOG_PATTERN, 8).alias("user_agent")
        ).filter(
            col("ip").isNotNull() & (col("ip") != "") &
            col("status").isNotNull()
        ).withColumn(
            "content_size",
            when(col("content_size_raw").isin("-", ""), 0)
            .otherwise(col("content_size_raw").cast("long"))
        ).drop("content_size_raw")

        # Parse timestamp
        parsed_df = parsed_df.withColumn(
            "log_time",
            to_date(col("timestamp"), "dd/MMM/yyyy:HH:mm:ss Z")
        ).withColumn(
            "process_time", lit(process_date).cast("date")
        ).filter(
            col("log_time").isNotNull()
        )

        # Create UA broadcast lookup
        broadcast_lookup = create_ua_broadcast_lookup(spark, parsed_df, logger)
        ua_lookup_udf = register_ua_lookup_udf(spark, broadcast_lookup)

        # Apply UA lookup
        ua_df = parsed_df.withColumn("ua_struct", ua_lookup_udf(col("user_agent")))

        # Final enriched dataframe
        enriched_df = ua_df.select(
            "process_time",
            "log_time",
            "ip",
            "method",
            "endpoint",
            "protocol",
            "status",
            "content_size",
            col("ua_struct.browser"),
            col("ua_struct.browser_version"),
            col("ua_struct.os"),
            col("ua_struct.os_version"),
            col("ua_struct.device_type"),
            col("ua_struct.is_mobile"),
            col("ua_struct.is_tablet"),
            col("ua_struct.is_pc"),
            col("ua_struct.is_bot")
        )

        # Write to Delta table
        logger.info(f"Writing to Delta table: {output_table}")
        enriched_df.write \
            .format("delta") \
            .mode("overwrite") \
            .option("replaceWhere", f"process_time = '{process_date}'") \
            .saveAsTable(output_table)

        # --- Collect and Update Metrics ---
        processed_count = enriched_df.count()
        bot_ip_count = enriched_df.filter(col("is_bot") == True).select("ip").distinct().count()
        total_duration = time.time() - job_start_time

        # Set the values for Prometheus Gauges
        logs_processed_metric.labels(**metric_labels).set(processed_count)
        bot_ips_metric.labels(**metric_labels).set(bot_ip_count)
        job_duration_seconds_metric.labels(**metric_labels).set(total_duration)
        job_status_metric.labels(**metric_labels).set(1) # Job succeeded

        logger.info(f"Successfully processed {processed_count:,} log entries")

        # --- Push metrics to Pushgateway ---
        logger.info(f"Pushing metrics to Pushgateway at {PUSHGATEWAY_URL}")
        try:
            # The 'job' argument is a mandatory grouping key.
            push_to_gateway(
                PUSHGATEWAY_URL,
                job=JOB_NAME,
                registry=registry,
                grouping_key={'process_date': process_date.strftime('%Y-%m-%d')}
            )
            logger.info("Metrics pushed successfully to Pushgateway.")
        except Exception as push_err:
            logger.error(f"Failed to push metrics to Pushgateway: {push_err}")

        # Cleanup
        broadcast_lookup.unpersist()
        raw_df.unpersist()

        return processed_count, bot_ip_count, total_duration

    except Exception as e:
        logger.error(f"Error during log processing: {e}")
        logger.exception("Full error traceback:")

        try:
            job_status_metric.labels(**metric_labels).set(0)
            push_to_gateway(
                PUSHGATEWAY_URL,
                job=JOB_NAME,
                registry=registry,
                grouping_key={'process_date': process_date.strftime('%Y-%m-%d')}
            )
            logger.info("Failure metrics pushed to Pushgateway.")
        except Exception as push_err:
            logger.error(f"Failed to push failure metrics to Pushgateway: {push_err}")

        raise
    finally:
        spark.catalog.clearCache()

def main():
    """Main execution entry point"""
    args = parse_arguments()
    process_date, input_path = validate_arguments_and_build_path(args)
    logger = setup_logging(args.process_date)
    spark = get_spark_session()

    start_time = datetime.now()

    logger.info("=" * 50)
    logger.info("STARTING APACHE LOG PROCESSING JOB")
    logger.info(f"Process Date: {args.process_date}")
    logger.info(f"Start Time: {start_time}")
    logger.info("=" * 50)

    try:
        logs_count, bot_ip_count, duration_seconds = process_apache_logs(
            spark=spark,
            input_path=input_path,
            process_date=process_date,
            output_table=OUTPUT_TABLE,
            logger=logger
        )

        end_time = datetime.now()

        logger.info("JOB COMPLETED SUCCESSFULLY")
        logger.info(f"Logs Processed: {logs_count:,}")
        logger.info(f"Bot IPs: {bot_ip_count:,}")
        logger.info(f"Job Duration: {duration_seconds:.2f} seconds")
        time.sleep(30)

    except Exception as e:
        logger.error("JOB FAILED")
        logger.error(f"Error: {e}")
        time.sleep(30) # Brief wait for any final error logs/metrics
        raise
    finally:
        logger.info("Apache log processing job finished")

if __name__ == "__main__":
    main()