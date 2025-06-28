import json
import os
import boto3
import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

sfn_arn = os.environ.get('STEP_FUNCTION_ARN')
sfn = boto3.client('stepfunctions')

cloudwatch = boto3.client('cloudwatch')

cognito = boto3.client('cognito-idp')
user_pool_id = os.environ.get('USER_POOL_ID')


def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}')) if 'body' in event else {}
    user_id = body.get("user_id")
    file_s3_key = body.get("file")
    approvers = body.get("approvers", [])

    if not user_id or not file_s3_key or not approvers:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': 'user_id, file, and approvers are required'})
        }

    try:
        timestamp = datetime.datetime.now().isoformat()  # Assuming you want to use the current timestamp
        items = []
        for approver in approvers:
            approverDataResponse = cognito.list_users(UserPoolId=user_pool_id, Filter=f"email = \"{approver}\"")
            approverId = approverDataResponse["Users"][0]["Username"]
            item = {
                "approverId": approverId,
                "approverEmail": approver,
                "submittedBy": user_id,
                "documentId": file_s3_key,
                "status": "PENDING",
                "submittedAt": timestamp,
                "message" : "",
                "finalStatus": "PENDING",
            }
            items.append(item)
            table.put_item(Item=item)

        response = sfn.start_execution(
            stateMachineArn=sfn_arn,
            input=json.dumps({
                "approvers": items,
            })
        )

        cloudwatch.put_metric_data(
            Namespace='DocuFlow',
            MetricData=[
                {
                    'MetricName': 'DocumentsSubmitted',
                    'Value': 1,
                    'Unit': 'Count',
                    'Dimensions': [
                        {
                            'Name': 'UserId',
                            'Value': user_id
                        }
                    ]
                }
            ]
        )
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': 'Document submitted successfully', 'execution_arn': response['executionArn']})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': str(e)})
        }
