#!/bin/bash

METASTORE_DB_INIT_FLAG="/opt/hive/metastore_db_initialized" # This flag is inside the container
LOG_FILE="/tmp/hive_metastore_init.log"

echo "$(date) - Checking if Hive Metastore schema is already initialized..." | tee -a "$LOG_FILE"

# Ensure HIVE_HOME is correctly set in this script's environment

# --- Validate required environment variables ---
if [ -z "$HIVE_METASTORE_JDBC_URL" ]; then
    echo "$(date) - ERROR: HIVE_METASTORE_JDBC_URL environment variable is not set." | tee -a "$LOG_FILE"
    exit 1
fi
if [ -z "$HIVE_METASTORE_USER" ]; then
    echo "$(date) - ERROR: HIVE_METASTORE_USER environment variable is not set." | tee -a "$LOG_FILE"
    exit 1
fi
if [ -z "$HIVE_METASTORE_PASSWORD" ]; then
    echo "$(date) - ERROR: HIVE_METASTORE_PASSWORD environment variable is not set." | tee -a "$LOG_FILE"
    exit 1
fi
# --- End validation ---

# Check for the local flag file first
if [ -f "$METASTORE_DB_INIT_FLAG" ]; then
    echo "$(date) - Hive Metastore schema already initialized in this container's history. Skipping schematool run." | tee -a "$LOG_FILE"
else
    echo "$(date) - Attempting to initialize Hive Metastore schema..." | tee -a "$LOG_FILE"

    # Execute schematool, using environment variables
    # Redirect stderr to stdout (2>&1) and then pipe to tee for logging
    $HIVE_HOME/bin/schematool \
    -initSchema \
    -dbType mysql \
    --userName "$HIVE_METASTORE_USER" \
    --passWord "$HIVE_METASTORE_PASSWORD" \
    --url "$HIVE_METASTORE_JDBC_URL" \
    --driver com.mysql.cj.jdbc.Driver 2>&1 | tee -a "$LOG_FILE"

    # Get the exit code of the schematool command specifically
    SCHEMA_TOOL_EXIT_CODE=${PIPESTATUS[0]}

    if [ $SCHEMA_TOOL_EXIT_CODE -eq 0 ]; then
        echo "$(date) - Hive Metastore schema initialization command completed successfully." | tee -a "$LOG_FILE"
        touch "$METASTORE_DB_INIT_FLAG" # Create the flag file only on success
    else
        # Check if the error is due to schema already existing (common scenario)
        # This is a heuristic; actual error message might vary slightly based on MySQL version/driver
        if grep -q "Table '.*' already exists" "$LOG_FILE" || grep -q "Duplicate entry" "$LOG_FILE"; then
            echo "$(date) - Hive Metastore schema appears to be already initialized in the Azure DB (detected 'already exists' or 'duplicate entry' error). Proceeding." | tee -a "$LOG_FILE"
            touch "$METASTORE_DB_INIT_FLAG" # Treat as success if it's just an "already exists" error
        else
            echo "$(date) - ERROR: Hive Metastore schema initialization failed with exit code $SCHEMA_TOOL_EXIT_CODE. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            exit 1 # Exit with error if it's a real failure
        fi
    fi
fi

echo "$(date) - Metastore initialization logic completed. Exiting init script." | tee -a "$LOG_FILE"
# When this script is run as a Kubernetes Job's `command`,
# it should exit after completion.
