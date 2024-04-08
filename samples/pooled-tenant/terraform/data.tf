#############################################################################
## Data Import
#############################################################################
data "aws_partition" "this" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "EKScluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "EKScluster" {
  name = var.cluster_name
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name = "tag:Type"

    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name = "tag:Type"

    values = ["public"]
  }
}

data "aws_iam_policy_document" "ssm_policy" {

  statement {
    sid    = "SSMPolicy"
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:DescribeParameters",
      "ssm:DeleteParameters"
    ]
    resources = ["arn:aws:ssm:${var.region}:${local.sts_caller_arn}:parameter/${var.namespace}/${var.environment}/pooled/*"]
  }
}

######################################################################################
## SSM Data
######################################################################################
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

data "aws_ssm_parameter" "cognito_user_pool_id" {
  name = "/${var.namespace}/${var.environment}/pooled/cognito_user_pool_id"
}

data "aws_ssm_parameter" "docker_username" {
  name = "/${var.namespace}/${var.environment}/docker_username"
}
data "aws_ssm_parameter" "docker_password" {
  name = "/${var.namespace}/${var.environment}/docker_password"
}

data "aws_ssm_parameter" "cognito_domain" {
  name = "/${var.namespace}/${var.environment}/pooled/cognito_domain"
}

data "aws_ssm_parameter" "cognito_id" {
  name       = "/${var.namespace}/${var.environment}/pooled/cognito_id"
  depends_on = [module.cognito_ssm_parameters]
}

data "aws_ssm_parameter" "cognito_secret" {
  name       = "/${var.namespace}/${var.environment}/pooled/cognito_secret"
  depends_on = [module.cognito_ssm_parameters]
}

data "aws_ssm_parameter" "db_user" {
  name = "/${var.namespace}/${var.environment}/pooled/db_user"
}

data "aws_ssm_parameter" "db_password" {
  name = "/${var.namespace}/${var.environment}/pooled/db_password"
}

data "aws_ssm_parameter" "db_host" {
  name = "/${var.namespace}/${var.environment}/pooled/db_host"
}

data "aws_ssm_parameter" "db_port" {
  name = "/${var.namespace}/${var.environment}/pooled/db_port"
}

data "aws_ssm_parameter" "db_schema" {
  name = "/${var.namespace}/${var.environment}/pooled/db_schema"
}

data "aws_ssm_parameter" "redis_host" {
  name = "/${var.namespace}/${var.environment}/pooled/redis_host"
}

data "aws_ssm_parameter" "redis_port" {
  name = "/${var.namespace}/${var.environment}/pooled/redis_port"
}

data "aws_ssm_parameter" "redis_database" {
  name = "/${var.namespace}/${var.environment}/pooled/redis-database"
}

data "aws_ssm_parameter" "authenticationdbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/authenticationdbdatabase"
}

data "aws_ssm_parameter" "auditdbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/auditdbdatabase"
}

data "aws_ssm_parameter" "notificationdbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/notificationdbdatabase"
}

data "aws_ssm_parameter" "schedulerdbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/schedulerdbdatabase"
}

data "aws_ssm_parameter" "userdbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/userdbdatabase"
}

data "aws_ssm_parameter" "videodbdatabase" {
  name = "/${var.namespace}/${var.environment}/pooled/videodbdatabase"
}

data "aws_ssm_parameter" "jwt_issuer" {
  name       = "/${var.namespace}/${var.environment}/pooled/${var.tenant}/jwt_issuer"
  depends_on = [module.jwt_ssm_parameters]
}

data "aws_ssm_parameter" "jwt_secret" {
  name       = "/${var.namespace}/${var.environment}/pooled/${var.tenant}/jwt_secret"
  depends_on = [module.jwt_ssm_parameters]
}

data "aws_ssm_parameter" "opensearch_domain" {
  name = "/${var.namespace}/${var.environment}/opensearch/domain_endpoint"
}

data "aws_ssm_parameter" "opensearch_username" {
  name = "/${var.namespace}/${var.environment}/opensearch/admin_username"
}

data "aws_ssm_parameter" "opensearch_password" {
  name = "/${var.namespace}/${var.environment}/opensearch/admin_password"
}

data "aws_ssm_parameter" "codebuild_role" {
  name = "/${var.namespace}/${var.environment}/codebuild_role"
}

