import json
import os
import boto3
import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    approvers = event.get('approvers', [])

    try:
        isApproved = True
        for approver in approvers:
            response = table.get_item(Key={"documentId": approver["documentId"], "approverId": approver["approverId"]})
            item = response.get('Item')
            if not item or item.get('status') != 'APPROVED':
                isApproved = False
                break
        # Update the document status to APPROVED
        for approver in approvers:
            table.update_item(
                Key={'documentId': approver["documentId"], 'approverId': approver["approverId"]},
                UpdateExpression='SET #status = :approved',
                ExpressionAttributeNames={'#status': 'finalStatus'},
                ExpressionAttributeValues={':approved': 'APPROVED' if isApproved else 'REJECTED'}
            )
        
        submittedTime = approvers[0].get('submittedAt', None)
        now = datetime.datetime.now().isoformat()
        # Update the final status of the document
        diff = datetime.datetime.fromisoformat(now) - datetime.datetime.fromisoformat(submittedTime)
        cloudwatch.put_metric_data(
            Namespace='DocuFlow',
            MetricData=[
                {
                    'MetricName': 'DocumentApprovalTime',
                    'Value': diff.total_seconds(),
                    'Unit': 'Seconds',
                    'Dimensions': [
                        {
                            'Name': 'UserId',
                            'Value': approvers[0]['submittedBy']
                        }
                    ]
                },
                {
                    'MetricName': "DocumentApprovalTime",
                    'Value': diff.total_seconds(),
                    'Unit': 'Seconds',
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
            'body': json.dumps({'message': f'Document was finally evaluated - {isApproved}'})
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