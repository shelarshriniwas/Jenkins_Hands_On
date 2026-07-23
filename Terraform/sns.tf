#############################################
# SNS Topic
#############################################

resource "aws_sns_topic" "alerts" {

  name = "production-alerts"

  tags = {
    Name        = "production-alerts"
    Environment = "dev"
    Project     = "terraform"
  }
}

#############################################
# Email Subscription
#############################################

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "email"

  endpoint = "admin@example.com"
}

#############################################
# SMS Subscription
#############################################

resource "aws_sns_topic_subscription" "sms" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "sms"

  endpoint = "+911234567890"
}

#############################################
# SQS Subscription
#############################################

resource "aws_sns_topic_subscription" "sqs" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "sqs"

  endpoint = aws_sqs_queue.alert_queue.arn
}

#############################################
# Lambda Subscription
#############################################

resource "aws_sns_topic_subscription" "lambda" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "lambda"

  endpoint = aws_lambda_function.alert_processor.arn
}

#############################################
# SNS Topic Policy
#############################################

resource "aws_sns_topic_policy" "alerts" {

  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AllowCloudWatch"

        Effect = "Allow"

        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }

        Action = "SNS:Publish"

        Resource = aws_sns_topic.alerts.arn

      }

    ]

  })

}

#############################################
# CloudWatch Alarm -> SNS
#############################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {

  alarm_name = "HighCPU"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  statistic = "Average"

  period = 120

  threshold = 70

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
# Outputs
#############################################

output "sns_topic_arn" {

  value = aws_sns_topic.alerts.arn

}

output "sns_topic_name" {

  value = aws_sns_topic.alerts.name

}