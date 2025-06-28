resource "aws_cloudwatch_log_group" "docuflow-sfn-log-group" {
    tags = {
      Project = "DocuFlow"
    }

    retention_in_days = 60
}

resource "aws_sfn_state_machine" "docuflow-sfn" {
    name = "DocuFlowStateMachine"
    role_arn = var.lab_role_arn
    definition = jsonencode(
        {
            Comment = "Docuflow Parallel Approval Workflow"
            StartAt = "NotifyApprovers"
            States = {
                NotifyApprovers = {
                    Type = "Map"
                    ItemsPath = "$.approvers"
                    MaxConcurrency = 0
                    ResultPath = null
                    Iterator = {
                        StartAt = "NotifyAndWait"
                        States = {
                            NotifyAndWait = {
                                Type = "Task"
                                Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
                                Parameters = {
                                    FunctionName = var.lambda-notify-users-arn
                                    Payload = {
                                        "taskToken.$" = "$$.Task.Token"
                                        "approver.$" = "$.approverId"
                                        "documentId.$" = "$.documentId"
                                        "approverEmail.$" = "$.approverEmail"
                                    }
                                }
                                TimeoutSeconds = 604800  # Timeout - 7 days
                                ResultPath = null
                                Catch = [
                                    {
                                        ErrorEquals = ["ImplicitRejected"]
                                        Next = "EndState"
                                    },
                                    {
                                        ErrorEquals = ["States.ALL"]
                                        Next = "MarkImplicitRejected"
                                    }
                                ]
                                End = true
                            }
                            MarkImplicitRejected = {
                                Type = "Task"
                                Resource = "arn:aws:states:::lambda:invoke"
                                Parameters = {
                                    FunctionName = var.lambda-implicit-rejection-arn
                                    Payload = {
                                        "Cause.$" = "$.Cause"
                                        "Error.$" = "$.Error"
                                    }
                                }
                                End = true
                            }
                            EndState = {
                                Type = "Pass"
                                End = true
                            }
                        }
                    }
                    Next = "EvaluateApprovalOutcome"
                }
                EvaluateApprovalOutcome = {
                    Type = "Task"
                    Resource = "arn:aws:states:::lambda:invoke"
                    Parameters = {
                        FunctionName = var.lambda-evaluate-approval-outcome-arn
                        Payload = {
                            "approvers.$" = "$.approvers"
                        }
                    }
                    End = true
                }
            }
        }
    )

    logging_configuration {
      level = "ALL"
      include_execution_data = true
      log_destination = "${aws_cloudwatch_log_group.docuflow-sfn-log-group.arn}:*"
    }

}

output "docuflow_sfn_arn" {
    value = aws_sfn_state_machine.docuflow-sfn.arn
}