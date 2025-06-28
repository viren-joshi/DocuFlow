resource "aws_cloudwatch_dashboard" "docuflow_dashboard" {
  dashboard_name = "DocuFlow-Metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "DocuFlow", "DocumentsSubmitted"]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "us-east-1",
          "title": "Documents Submitted (Count)"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "DocuFlow", "DocumentApprovalTime"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "Average Approval Time (Seconds)"
        }
      }
    ]
  })
}
