locals {
  include_cloudfront = var.cloudfront_distribution_id != ""
  include_alb        = var.alb_arn_suffix != ""
  include_ecs        = length(var.ecs_services) > 0
  include_rds        = var.rds_instance_identifier != ""

  # ============================================================
  # CloudFront widgets (us-east-1 only)
  # ============================================================
  cloudfront_widgets_def = [
    {
      type   = "text"
      x      = 0
      y      = 0
      width  = 24
      height = 1
      properties = {
        markdown = "## CloudFront${var.cloudfront_label != "" ? ": ${var.cloudfront_label}" : ""}"
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 1
      width  = 8
      height = 6
      properties = {
        title   = "Requests"
        region  = "us-east-1"
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id, "Region", "Global"]
        ]
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 1
      width  = 8
      height = 6
      properties = {
        title   = "Cache Hit Rate (%)"
        region  = "us-east-1"
        period  = var.period
        stat    = "Average"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global"]
        ]
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 1
      width  = 8
      height = 6
      properties = {
        title   = "Error Rate (%)"
        region  = "us-east-1"
        period  = var.period
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", color = "#d62728" }],
          ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", color = "#ff7f0e" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 7
      width  = 8
      height = 6
      properties = {
        title   = "Origin Latency (ms)"
        region  = "us-east-1"
        period  = var.period
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/CloudFront", "OriginLatency", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "p90" }],
          ["AWS/CloudFront", "OriginLatency", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "p50" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 7
      width  = 8
      height = 6
      properties = {
        title   = "Bytes Downloaded"
        region  = "us-east-1"
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/CloudFront", "BytesDownloaded", "DistributionId", var.cloudfront_distribution_id, "Region", "Global"]
        ]
      }
    }
  ]
  cloudfront_widgets = [for w in local.cloudfront_widgets_def : w if local.include_cloudfront]

  # Section heights for y-offset calculation
  cf_height  = local.include_cloudfront ? 13 : 0
  alb_offset = local.cf_height

  # ============================================================
  # ALB widgets (optional)
  # ============================================================
  alb_widgets_def = [
    {
      type   = "text"
      x      = 0
      y      = local.alb_offset
      width  = 24
      height = 1
      properties = {
        markdown = "## ALB${var.alb_label != "" ? ": ${var.alb_label}" : ""}"
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = local.alb_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "Request Count"
        region  = var.region
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
        ]
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = local.alb_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "Target Response Time (s)"
        region  = var.region
        period  = var.period
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p90", label = "p90" }],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p99", label = "p99" }],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "Average", label = "Average" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = local.alb_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "5XX Errors"
        region  = var.region
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = true
        metrics = [
          ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { color = "#d62728", label = "Target 5XX" }],
          ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { color = "#9467bd", label = "ELB 5XX" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = local.alb_offset + 7
      width  = 8
      height = 6
      properties = {
        title   = "Active Connections"
        region  = var.region
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", var.alb_arn_suffix]
        ]
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = local.alb_offset + 7
      width  = 8
      height = 6
      properties = {
        title   = "Healthy Host Count"
        region  = var.region
        period  = var.period
        stat    = "Minimum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.target_group_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
        ]
      }
    }
  ]
  alb_widgets = [for w in local.alb_widgets_def : w if local.include_alb]

  alb_height = local.include_alb ? 13 : 0
  ecs_offset = local.alb_offset + local.alb_height

  # ============================================================
  # ECS widgets (optional, multiple services)
  # ============================================================
  ecs_widgets = flatten([
    for i, svc in var.ecs_services : [
      {
        type   = "text"
        x      = 0
        y      = local.ecs_offset + (i * 7)
        width  = 24
        height = 1
        properties = {
          markdown = "## ECS: ${svc.label != "" ? svc.label : svc.service_name}"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = local.ecs_offset + (i * 7) + 1
        width  = 8
        height = 6
        properties = {
          title   = "CPU Utilization (%)"
          region  = var.region
          period  = var.period
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { stat = "Average", label = "Average" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { stat = "Maximum", label = "Maximum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = local.ecs_offset + (i * 7) + 1
        width  = 8
        height = 6
        properties = {
          title   = "Memory Utilization (%)"
          region  = var.region
          period  = var.period
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { stat = "Average", label = "Average" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { stat = "Maximum", label = "Maximum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = local.ecs_offset + (i * 7) + 1
        width  = 8
        height = 6
        properties = {
          title   = "Task Count"
          region  = var.region
          period  = var.period
          stat    = "Average"
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { label = "Running" }],
            ["ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", svc.cluster_name, "ServiceName", svc.service_name, { label = "Desired" }]
          ]
        }
      }
    ]
  ])

  ecs_height = length(var.ecs_services) * 7
  rds_offset = local.ecs_offset + local.ecs_height

  # ============================================================
  # RDS widgets (optional)
  # ============================================================
  rds_widgets_def = [
    {
      type   = "text"
      x      = 0
      y      = local.rds_offset
      width  = 24
      height = 1
      properties = {
        markdown = "## RDS${var.rds_label != "" ? ": ${var.rds_label}" : ""}"
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = local.rds_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "CPU Utilization (%)"
        region  = var.region
        period  = var.period
        stat    = "Average"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_identifier]
        ]
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = local.rds_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "Database Connections"
        region  = var.region
        period  = var.period
        stat    = "Sum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_identifier]
        ]
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = local.rds_offset + 1
      width  = 8
      height = 6
      properties = {
        title   = "Read / Write Latency (s)"
        region  = var.region
        period  = var.period
        stat    = "Average"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", var.rds_instance_identifier, { label = "Read" }],
          ["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", var.rds_instance_identifier, { label = "Write" }]
        ]
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = local.rds_offset + 7
      width  = 8
      height = 6
      properties = {
        title   = "Freeable Memory (bytes)"
        region  = var.region
        period  = var.period
        stat    = "Minimum"
        view    = "timeSeries"
        stacked = false
        metrics = [
          ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", var.rds_instance_identifier]
        ]
      }
    }
  ]
  rds_widgets = [for w in local.rds_widgets_def : w if local.include_rds]

  all_widgets = concat(
    local.cloudfront_widgets,
    local.alb_widgets,
    local.ecs_widgets,
    local.rds_widgets,
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.name
  dashboard_body = jsonencode({ widgets = local.all_widgets })
}
