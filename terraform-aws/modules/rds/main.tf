module "rds" {
    source = "terraform-aws-modules/rds/aws"
    version = "~> 6.1"

    identifier = "${var.name_prefix}-hms"

    # Database configurations
    engine               = "mysql"
    engine_version       = "8.0"
    family               = "mysql8.0"
    major_engine_version = "8.0"
    instance_class       = var.db_instance_class

    # Minimum storage for free tier
    allocated_storage     = 20
    max_allocated_storage = 20

    db_name  = var.db_name
    username = var.db_username
    password = var.db_password
    port     = 3306

    # Free tier optimizations
    multi_az               = false
    db_subnet_group_name   = var.db_subnet_group_name
    vpc_security_group_ids = [var.rds_security_group_id]

    # Disable maintenance window for free tier
    maintenance_window = null
    backup_window      = null

    # Disable backups for free tier
    backup_retention_period = 0
    skip_final_snapshot     = true
    deletion_protection     = false

    # Disable monitoring and insights to reduce costs
    performance_insights_enabled = false
    monitoring_interval          = 0
    enabled_cloudwatch_logs_exports = []

    # Basic parameter group
    parameters = [
      {
        name  = "character_set_server"
        value = "utf8mb4"
      },
      {
        name  = "character_set_client"
        value = "utf8mb4"
      }
    ]

    tags = var.tags
  }