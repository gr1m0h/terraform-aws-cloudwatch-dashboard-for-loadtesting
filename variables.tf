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
  description = "CloudFront distribution ID. Leave empty to omit the CloudFront section. NOTE: the Cache Hit Rate and Origin Latency widgets require \"Additional CloudWatch metrics\" enabled on the distribution; without it those widgets render as \"No data\"."
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
  description = "List of ECS services to monitor. Leave empty to omit the ECS section. NOTE: the Task Count widget requires Container Insights enabled on the cluster — without it RunningTaskCount/DesiredTaskCount render as \"No data\"."
  type = list(object({
    cluster_name = string
    service_name = string
    label        = optional(string, "")
  }))
  default = []

  validation {
    condition = alltrue([
      for s in var.ecs_services : s.cluster_name != "" && s.service_name != ""
    ])
    error_message = "Each ecs_services entry must have a non-empty cluster_name and service_name."
  }
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
  description = "Metric aggregation period in seconds. Valid values: 1, 5, 10, 30 (high-resolution) or any multiple of 60 up to 86400."
  type        = number
  default     = 60

  validation {
    condition     = contains([1, 5, 10, 30], var.period) || (var.period >= 60 && var.period <= 86400 && var.period % 60 == 0)
    error_message = "period must be one of 1, 5, 10, 30, or a multiple of 60 up to 86400."
  }
}
