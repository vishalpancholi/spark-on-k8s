# Website Log Analytics Pipeline on Azure

This repository outlines a scalable data pipeline for processing website log data, generating analytical insights, and storing results using Apache Spark and Delta Lake on Azure.

## Overview

Transforms raw website logs into actionable daily and weekly analytics (e.g., top IPs, devices). The pipeline follows a Bronze -> Silver -> Gold architecture using Spark on Kubernetes with Delta Lake for data reliability and performance.

## Key Technologies

* **Platform:** Microsoft Azure
* **Infrastructure as Code (IaC):** Terraform
* **Compute:** Apache Spark 3.5.1 on Azure Kubernetes Service (AKS)
* **Data Format:** Delta Lake
* **Storage:** Azure Blob Storage
* **Metastore:** Azure SQL Database
* **Monitoring:** Spark UI, Kube-Prometheus-Stack

## Pipeline Stages

1.  **Raw Data Ingestion:** Logs (text files) are uploaded to Azure Blob Storage.
2.  **Data Transformation (Spark Job 1):** Logs are parsed, cleaned, and stored as a structured Delta table in Azure Blob Storage.
3.  **Analytical Aggregation (Spark Job 2):** Queries processed data to create aggregated Delta tables (e.g., top IPs/devices).

## Performance & Maintenance

* **Delta Lake:** Strategic use of `OPTIMIZE` (including `ZORDER BY`) for query performance and `VACUUM` for storage management.
* **Spark Tuning:** Configured for `Standard_B2pls_v2` nodes with optimized memory, CPU, shuffle partitions, and Adaptive Query Execution (AQE).

## Monitoring

* **Spark UI:** Detailed job execution and resource utilization.
* **Kube-Prometheus-Stack:** Collects and visualizes in-depth Spark JVM, Executor, Shuffle, Task, and SQL metrics via JMX Exporters.

## Setup

* `terraform-azure/`: Contains Terraform code for provisioning Azure infrastructure.
    * **For detailed infrastructure creation and setup instructions, please refer to the `README.md` file located inside the `terraform-azure/` directory**

---
*For a detailed breakdown of the design, configurations, and implementation, please refer to the comprehensive design document attached in the mail*