################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

################################################################################
## tags
################################################################################
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.5"

  environment = var.environment
  project     = var.namespace

}

################################################################################
## db
################################################################################
module "db_password" {
  source           = "../../modules/random-password"
  length           = 16
  is_special       = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "aurora" {
  source  = "sourcefuse/arc-db/aws"
  version = "2.0.5"


  environment = var.environment
  namespace   = var.namespace
  region      = var.region
  vpc_id      = data.aws_vpc.vpc.id

  aurora_cluster_enabled                    = var.aurora_cluster_enabled
  aurora_cluster_name                       = "${var.namespace}-${var.environment}-aurora"
  enhanced_monitoring_name                  = "${var.namespace}-${var.environment}-enhanced-monitoring"
  aurora_db_admin_username                  = var.aurora_db_admin_username
  aurora_db_admin_password                  = module.db_password.result
  aurora_db_name                            = var.aurora_db_name
  aurora_db_port                            = var.aurora_db_port
  aurora_cluster_family                     = var.aurora_cluster_family
  aurora_engine                             = var.aurora_engine
  aurora_engine_mode                        = var.aurora_engine_mode
  aurora_storage_type                       = var.aurora_storage_type
  aurora_engine_version                     = var.aurora_engine_version
  aurora_allow_major_version_upgrade        = var.aurora_allow_major_version_upgrade
  aurora_auto_minor_version_upgrade         = var.aurora_auto_minor_version_upgrade
  aurora_instance_type                      = var.aurora_instance_type
  aurora_subnets                            = data.aws_subnets.private.ids
  aurora_allowed_cidr_blocks                = [data.aws_vpc.vpc.cidr_block]
  aurora_serverlessv2_scaling_configuration = var.aurora_serverlessv2_scaling_configuration
  performance_insights_enabled              = var.performance_insights_enabled
  performance_insights_retention_period     = var.performance_insights_retention_period
  iam_database_authentication_enabled       = var.iam_database_authentication_enabled
  aurora_cluster_size                       = var.aurora_cluster_size
  tags = merge(
    module.tags.tags
  )
}

#######################################################################
## Security Group ingress rules
#######################################################################


resource "aws_security_group_rule" "additional_inbound_rules" {

  depends_on = [module.aurora]

  count             = length(var.additional_inbound_rules)
  security_group_id = data.aws_security_groups.aurora.ids[0]
  description       = var.additional_inbound_rules[count.index].description
  from_port         = var.additional_inbound_rules[count.index].from_port
  to_port           = var.additional_inbound_rules[count.index].to_port
  protocol          = var.additional_inbound_rules[count.index].protocol
  cidr_blocks       = var.additional_inbound_rules[count.index].cidr_blocks
  type              = "ingress"

}

########################################################################
## Store DB Configs in Parameter Store
########################################################################

module "ssm_db_user" {
  source                    = "../../modules/ssm-parameter"
  ssm_parameter_name        = "/${var.namespace}/${var.environment}/db_user"
  ssm_parameter_description = "Database user name"
  ssm_parameter_type        = "SecureString"
  ssm_parameter_overwrite   = true
  ssm_parameter_value       = var.aurora_db_admin_username
  tags                      = module.tags.tags
  depends_on                = [module.aurora]
}

module "ssm_db_password" {
  source                    = "../../modules/ssm-parameter"
  ssm_parameter_name        = "/${var.namespace}/${var.environment}/db_password"
  ssm_parameter_description = "Database password"
  ssm_parameter_type        = "SecureString"
  ssm_parameter_overwrite   = true
  ssm_parameter_value       = module.db_password.result
  tags                      = module.tags.tags
  depends_on                = [module.aurora, module.db_password]
}

module "ssm_db_host" {
  source                    = "../../modules/ssm-parameter"
  ssm_parameter_name        = "/${var.namespace}/${var.environment}/db_host"
  ssm_parameter_description = "Database Host"
  ssm_parameter_type        = "SecureString"
  ssm_parameter_overwrite   = true
  ssm_parameter_value       = module.aurora.aurora_endpoint
  tags                      = module.tags.tags
  depends_on                = [module.aurora]
}

module "ssm_db_port" {
  source                    = "../../modules/ssm-parameter"
  ssm_parameter_name        = "/${var.namespace}/${var.environment}/db_port"
  ssm_parameter_description = "Database Port"
  ssm_parameter_type        = "SecureString"
  ssm_parameter_overwrite   = true
  ssm_parameter_value       = var.aurora_db_port
  tags                      = module.tags.tags
  depends_on                = [module.aurora]
}

# ############################################################################
# ## Postgres provder to create DB & store in parameter store
# ############################################################################
# provider "postgresql" {
#   host      = module.rds.instance_address
#   port      = var.aurora_db_port
#   database  = var.aurora_db_name
#   username  = var.aurora_db_user
#   password  = random_password.db_password.result
#   sslmode   = "require"
#   superuser = false

# }
# resource "postgresql_database" "audit_db" {
#   name              = var.auditdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "authentication_db" {
#   name              = var.authenticationdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "notification_db" {
#   name              = var.notificationdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "subscription_db" {
#   name              = var.subscriptiondbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "user_db" {
#   name              = var.userdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "payment_db" {
#   name              = var.paymentdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "tenant_mgmt_db" {
#   name              = var.tenantmgmtdbdatabase
#   allow_connections = true
# }
# resource "postgresql_database" "feature_db" {
#   name              = var.featuretoggledbdatabase
#   allow_connections = true
# }
