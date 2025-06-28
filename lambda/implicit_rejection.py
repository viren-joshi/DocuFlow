import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

sfn = boto3.client('stepfunctions')

def lambda_handler(event, context):
    cause = json.loads(event["Cause"])
    print(cause)
    approver_id = cause["approverId"]
    document_id = cause["documentId"]
    
    if not document_id or not approver_id:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'documentId and approverId are required'})
        }
    try:
        # Get all other approvers for the document  
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('documentId').eq(document_id)
        )
        other_approvers = response.get('Items', [])
        for approver in other_approvers:
            if approver['approverId'] == approver_id:
                continue
            sfn.send_task_failure(
                taskToken=approver['taskToken'],
                error='ImplicitRejected',
                cause='Document has been implicitly rejected by another approver.'
            )

            table.update_item(
                Key={
                    'approverId': approver['approverId'],
                    'documentId': document_id
                },
                UpdateExpression='SET #status = :rejected',
                ExpressionAttributeNames={
                    '#status': 'status'
                },
                ExpressionAttributeValues={
                    ':rejected': 'REJECTED_IMPLICIT'
                }
            )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': str(e)})
        }