# CloudWatch Alarms for ECS Service

# Alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "${var.app_name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "Alert when ECS CPU exceeds 90%"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.coffee_api.name
  }
}

# Alarm for memory utilization
resource "aws_cloudwatch_metric_alarm" "ecs_memory_utilization" {
  alarm_name          = "${var.app_name}-high-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "Alert when ECS memory exceeds 90%"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.coffee_api.name
  }
}

# Alarm for unhealthy targets
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.app_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when unhealthy hosts exceed 0"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.coffee_api.arn_suffix
  }
}

# Alarm for ALB request count
resource "aws_cloudwatch_metric_alarm" "alb_request_count" {
  alarm_name          = "${var.app_name}-high-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10000"
  alarm_description   = "Alert when request count exceeds 10000 in 5 minutes"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# Alarm for ALB target response time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.app_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1" # 1 second
  alarm_description   = "Alert when response time exceeds 1 second"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average", label = "CPU Utilization" }],
            [".", "MemoryUtilization", { stat = "Average", label = "Memory Utilization" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ECS Service Metrics"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "UnHealthyHostCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Metrics"
        }
      },
      {
        type = "log"
        properties = {
          query = "fields @timestamp, @message | stats count() by @logStream"
          region = data.aws_region.current.name
          title = "Log Streams"
        }
      }
    ]
  })
}
