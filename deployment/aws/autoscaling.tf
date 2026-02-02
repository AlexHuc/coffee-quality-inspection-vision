# This file is intentionally left minimal as auto-scaling
# configuration is already defined in ecs.tf
#
# Additional auto-scaling features can be added here:
# - Scheduled scaling
# - Custom metric scaling
# - Lifecycle hooks

# Example: Scheduled scaling for predictable traffic patterns
# resource "aws_appautoscaling_scheduled_action" "scale_up_morning" {
#   count              = var.enable_auto_scaling ? 1 : 0
#   service_namespace  = "ecs"
#   schedule           = "cron(0 8 * * MON-FRI *)"  # 8 AM UTC on weekdays
#   timezone           = "UTC"
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.coffee_api.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   start_time         = null
#   end_time           = null
#   scalable_target_action {
#     max_capacity = 10
#     min_capacity = 5
#   }
# }
#
# resource "aws_appautoscaling_scheduled_action" "scale_down_evening" {
#   count              = var.enable_auto_scaling ? 1 : 0
#   service_namespace  = "ecs"
#   schedule           = "cron(0 18 * * MON-FRI *)"  # 6 PM UTC on weekdays
#   timezone           = "UTC"
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.coffee_api.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   start_time         = null
#   end_time           = null
#   scalable_target_action {
#     max_capacity = 4
#     min_capacity = 1
#   }
# }
