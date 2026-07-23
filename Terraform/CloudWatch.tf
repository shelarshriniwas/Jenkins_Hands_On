#############################################
# CloudWatch Log Group
#############################################

resource "aws_cloudwatch_log_group" "application" {

  name              = "/aws/ec2/application"
  retention_in_days = 30

  tags = {
    Name = "application-log-group"
  }
}

#############################################
# SNS Topic
#############################################

resource "aws_sns_topic" "alerts" {

  name = "cloudwatch-alerts"

  tags = {
    Name = "cloudwatch-alerts"
  }
}

#############################################
# SNS Email Subscription
#############################################

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "admin@example.com"

}

#############################################
# CPU High Alarm
#############################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {

  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 120
  statistic = "Average"

  threshold = 70

  alarm_description = "CPU exceeds 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]
}

#############################################
# CPU Low Alarm
#############################################

resource "aws_cloudwatch_metric_alarm" "cpu_low" {

  alarm_name          = "LowCPU"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 120
  statistic = "Average"

  threshold = 20

  alarm_description = "CPU below 20%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]
}

#############################################
# Status Check Failed Alarm
#############################################

resource "aws_cloudwatch_metric_alarm" "status_check" {

  alarm_name          = "StatusCheckFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "StatusCheckFailed"
  namespace   = "AWS/EC2"

  period    = 60
  statistic = "Maximum"

  threshold = 0

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

#############################################
# Network In Alarm
#############################################

resource "aws_cloudwatch_metric_alarm" "network_in" {

  alarm_name          = "HighNetworkIn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "NetworkIn"
  namespace   = "AWS/EC2"

  statistic = "Average"

  period = 300

  threshold = 100000000

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

#############################################
# Network Out Alarm
#############################################

resource "aws_cloudwatch_metric_alarm" "network_out" {

  alarm_name          = "HighNetworkOut"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "NetworkOut"
  namespace   = "AWS/EC2"

  statistic = "Average"

  period = 300

  threshold = 100000000

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}

#############################################
# CloudWatch Dashboard
#############################################

resource "aws_cloudwatch_dashboard" "dashboard" {

  dashboard_name = "Production-Dashboard"

  dashboard_body = jsonencode({

    widgets = [

      {
        type = "metric"

        x = 0
        y = 0

        width = 12
        height = 6

        properties = {

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              aws_autoscaling_group.web_asg.name
            ]
          ]

          period = 300

          stat = "Average"

          region = "ap-south-1"

          title = "EC2 CPU Utilization"

        }

      },

      {
        type = "metric"

        x = 12
        y = 0

        width = 12
        height = 6

        properties = {

          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "AutoScalingGroupName",
              aws_autoscaling_group.web_asg.name
            ]
          ]

          period = 300

          stat = "Average"

          region = "ap-south-1"

          title = "Network In"

        }

      }

    ]

  })

}