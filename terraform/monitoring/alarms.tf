
resource "aws_sns_topic" "approval_delay_topic" {
  name = "approval-delay-alert"
}

resource "aws_sns_topic_subscription" "approval_delay_email" {
  topic_arn = aws_sns_topic.approval_delay_topic.arn
  protocol  = "email"
  endpoint  = "viren.joshi@dal.ca"
}


resource "aws_cloudwatch_metric_alarm" "approval_duration_alarm" {
  alarm_name          = "HighApprovalDuration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DocumentApprovalTime"
  namespace           = "DocuFlow"
  period              = 3600  # 1 hour
  statistic           = "Average"
  threshold           = 518400  # 6 days in seconds
  alarm_description   = "Triggers if average approval time exceeds 6 days"

  alarm_actions = [
    aws_sns_topic.approval_delay_topic.arn
  ]
}
