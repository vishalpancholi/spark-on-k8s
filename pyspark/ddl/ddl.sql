# 1. processed_data
CREATE TABLE IF NOT EXISTS processed_data (
  process_time      DATE,
  log_time          DATE,
  ip                STRING,
  method            STRING,
  endpoint          STRING,
  protocol          STRING,
  status            INT,
  content_size      BIGINT,
  browser           STRING,
  browser_version   STRING,
  os                STRING,
  os_version        STRING,
  device_type       STRING,
  is_mobile         BOOLEAN,
  is_tablet         BOOLEAN,
  is_pc             BOOLEAN,
  is_bot            BOOLEAN
)
USING DELTA
PARTITIONED BY (process_time, log_time)
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/processed_data/';

-------------------------------------------------------------------------------------------------------
# daily tables
-------------------------------------------------------------------------------------------------------

# 1. top_ips_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_ips_daily (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_ips_daily'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 2. top_device_types_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_device_types_daily (
  process_time DATE,
  log_time DATE,
  device_type STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_device_types_daily'
PARTITIONED BY (process_time, log_time, device_type)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 3. top_endpoints_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_endpoints_daily (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_endpoints_daily'
PARTITIONED BY (process_time, log_time, endpoint)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 4. top_browsers_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_browsers_daily (
  process_time DATE,
  log_time DATE,
  browser STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_browsers_daily'
PARTITIONED BY (process_time, log_time, browser)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 5. top_os_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_os_daily (
  process_time DATE,
  log_time DATE,
  os STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_os_daily'
PARTITIONED BY (process_time, log_time, os)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 6. top_content_size_daily
spark.sql("""
CREATE TABLE IF NOT EXISTS top_content_size_daily (
  process_time DATE,
  log_time DATE,
  content_size BIGINT,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_content_size_daily'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 7. top_bot_ips_daily (is_bot=true)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_bot_ips_daily (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_bot_ips_daily'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 8. top_failed_status_ips_daily (status = 4xx & 5xx)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_failed_status_ips_daily (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_failed_status_ips_daily'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 9. top_endpoints_access_by_bots_daily (is_bot=true)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_endpoints_access_by_bots_daily (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_endpoints_access_by_bots_daily'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 10. top_failed_endpoints_daily (status = 4xx & 5xx)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_failed_endpoints_daily (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/daily/top_failed_endpoints_daily'
PARTITIONED BY (process_time, log_time, endpoint)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------
# weekly tables
-------------------------------------------------------------------------------------------------------
# 1. top_ips_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_ips_weekly (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_ips_weekly'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 2. top_device_types_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_device_types_weekly (
  process_time DATE,
  log_time DATE,
  device_type STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_device_types_weekly'
PARTITIONED BY (process_time, log_time, device_type)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 3. top_endpoints_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_endpoints_weekly (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_endpoints_weekly'
PARTITIONED BY (process_time, log_time, endpoint)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 4. top_browsers_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_browsers_weekly (
  process_time DATE,
  log_time DATE,
  browser STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_browsers_weekly'
PARTITIONED BY (process_time, log_time, browser)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 5. top_os_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_os_weekly (
  process_time DATE,
  log_time DATE,
  os STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_os_weekly'
PARTITIONED BY (process_time, log_time, os)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 6. top_content_size_weekly
spark.sql("""
CREATE TABLE IF NOT EXISTS top_content_size_weekly (
  process_time DATE,
  log_time DATE,
  content_size BIGINT,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_content_size_weekly'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 7. top_bot_ips_weekly (is_bot=true)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_bot_ips_weekly (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_bot_ips_weekly'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 8. top_failed_status_ips_weekly (status = 4xx & 5xx)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_failed_status_ips_weekly (
  process_time DATE,
  log_time DATE,
  ip STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_failed_status_ips_weekly'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 9. top_endpoints_access_by_bots_weekly (is_bot=true)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_endpoints_access_by_bots_weekly (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_endpoints_access_by_bots_weekly'
PARTITIONED BY (process_time, log_time)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
-------------------------------------------------------------------------------------------------------

# 10. top_failed_endpoints_weekly (status = 4xx & 5xx)
spark.sql("""
CREATE TABLE IF NOT EXISTS top_failed_endpoints_weekly (
  process_time DATE,
  log_time DATE,
  endpoint STRING,
  count BIGINT
)
USING DELTA
LOCATION 'abfss://transformed@granicasa.dfs.core.windows.net/data/weekly/top_failed_endpoints_weekly'
PARTITIONED BY (process_time, log_time, endpoint)
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
""")
