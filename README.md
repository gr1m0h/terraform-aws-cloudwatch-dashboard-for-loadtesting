# terraform-aws-cloudwatch-dashboard-for-loadtesting

Terraform module to create a CloudWatch dashboard for load testing. Each service section (CloudFront, ALB, ECS, RDS) is optional and can be toggled by providing the corresponding variables.

## Usage

```hcl
module "load_test_dashboard" {
  source = "github.com/gr1m0h/terraform-aws-cloudwatch-dashboard-for-loadtesting"

  name = "svc-load-test"

  # CloudFront (optional)
  cloudfront_distribution_id = "E1ABCDEF123456"
  cloudfront_label           = "stg-svc"

  # ALB (optional)
  alb_arn_suffix         = "app/stg-svc-alb/1234567890abcdef"
  target_group_arn_suffix = "targetgroup/stg-svc-tg/abcdef1234567890"
  alb_label              = "stg-svc"

  # ECS (optional, supports multiple services)
  ecs_services = [
    {
      cluster_name = "stg-svc"
      service_name = "stg-svc-front"
      label        = "svc-front"
    },
    {
      cluster_name = "stg-svc"
      service_name = "stg-svc-back"
      label        = "svc-back"
    },
  ]

  # RDS (optional)
  rds_instance_identifier = "stg-svc-db"
  rds_label               = "stg-db"
}
```

## Dashboard Sections

| Section    | Metrics                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| CloudFront | Requests, Cache Hit Rate, Error Rate (4xx/5xx), Origin Latency (p50/p90), Bytes Downloaded            |
| ALB        | Request Count, Target Response Time (p90/p99/Avg), 5XX Errors, Active Connections, Healthy Host Count |
| ECS        | CPU Utilization (Avg/Max), Memory Utilization (Avg/Max), Task Count (Running/Desired)                 |
| RDS        | CPU Utilization, Database Connections, Read/Write Latency, Freeable Memory                            |

### Source Feature Requirements

Some widgets depend on features that must be enabled on the underlying AWS resource. Without them the widgets render as "No data":

| Widget                                              | Required source feature                                                                                                                                       |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CloudFront `Cache Hit Rate`, `Origin Latency`       | [Additional CloudWatch metrics](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/viewing-cloudfront-metrics.html#monitoring-console.additional) on the distribution (paid). Basic CloudFront metrics (Requests, 4xx/5xx, BytesDownloaded) work without it. |
| ECS `Task Count` (Running/Desired)                  | [Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-ECS-cluster.html) enabled on the cluster — these metrics are in the `ECS/ContainerInsights` namespace. CPU/Memory work without it. |

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.13.0 |
| aws       | >= 6.17.0 |

## Resources

| Name                                                                                                                              | Type     |
| --------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_dashboard.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |

## Inputs

| Name                       | Description                                                                                         | Type                                                                                           | Default                       | Required |
| -------------------------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------- | :------: |
| name                       | Dashboard name                                                                                      | `string`                                                                                       | `"dashboard_for_loadtesting"` |    no    |
| region                     | AWS region                                                                                          | `string`                                                                                       | `"ap-northeast-1"`            |    no    |
| cloudfront_distribution_id | CloudFront distribution ID. Leave empty to omit the CloudFront section.                             | `string`                                                                                       | `""`                          |    no    |
| cloudfront_label           | Label for CloudFront section header (e.g. distribution name).                                       | `string`                                                                                       | `""`                          |    no    |
| alb_arn_suffix             | ALB ARN suffix (e.g. `app/my-alb/1234567890`). Leave empty to omit the ALB section.                 | `string`                                                                                       | `""`                          |    no    |
| target_group_arn_suffix    | Target group ARN suffix (e.g. `targetgroup/my-tg/1234567890`). Required when alb_arn_suffix is set. | `string`                                                                                       | `""`                          |    no    |
| alb_label                  | Label for ALB section header (e.g. ALB name).                                                       | `string`                                                                                       | `""`                          |    no    |
| ecs_services               | List of ECS services to monitor. Leave empty to omit the ECS section.                               | `list(object({ cluster_name = string, service_name = string, label = optional(string, "") }))` | `[]`                          |    no    |
| rds_instance_identifier    | RDS instance identifier. Leave empty to omit the RDS section.                                       | `string`                                                                                       | `""`                          |    no    |
| rds_label                  | Label for RDS section header (e.g. instance name).                                                  | `string`                                                                                       | `""`                          |    no    |
| period                     | Metric aggregation period in seconds                                                                | `number`                                                                                       | `60`                          |    no    |

## Outputs

| Name           | Description                                                |
| -------------- | ---------------------------------------------------------- |
| dashboard_arn  | CloudWatch dashboard ARN                                   |
| dashboard_name | CloudWatch dashboard name                                  |
| dashboard_url  | URL to open the dashboard in the CloudWatch console        |
