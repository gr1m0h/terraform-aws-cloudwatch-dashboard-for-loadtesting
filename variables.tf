variable "name" {
  description = "Dashboard name"
  type        = string
  default     = "dashboard_for_loadtesting"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

# CloudFront (optional)
variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID. Leave empty to omit the CloudFront section."
  type        = string
  default     = ""
}

variable "cloudfront_label" {
  description = "Label for CloudFront section header (e.g. distribution name)."
  type        = string
  default     = ""
}

# ALB (optional)
variable "alb_arn_suffix" {
  description = "ALB ARN suffix (e.g. app/my-alb/1234567890). Leave empty to omit the ALB section."
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix (e.g. targetgroup/my-tg/1234567890). Required when alb_arn_suffix is set."
  type        = string
  default     = ""
}

variable "alb_label" {
  description = "Label for ALB section header (e.g. ALB name)."
  type        = string
  default     = ""
}

# ECS (optional)
variable "ecs_services" {
  description = "List of ECS services to monitor. Leave empty to omit the ECS section."
  type = list(object({
    cluster_name = string
    service_name = string
    label        = optional(string, "")
  }))
  default = []
}

# RDS (optional)
variable "rds_instance_identifier" {
  description = "RDS instance identifier. Leave empty to omit the RDS section."
  type        = string
  default     = ""
}

variable "rds_label" {
  description = "Label for RDS section header (e.g. instance name)."
  type        = string
  default     = ""
}

variable "period" {
  description = "Metric aggregation period in seconds"
  type        = number
  default     = 60
}
