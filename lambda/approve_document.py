import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

sfn = boto3.client('stepfunctions')

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}')) if 'body' in event else {}
    approverId = body.get('approverId')
    documentId = body.get('documentId')
    isApproved = body.get('isApproved')
    message = body.get('message', '')

    if not approverId or not documentId or isApproved is None:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': 'approverId, documentId, and decision are required'})
        }

    # Update the document status in DynamoDB
    status = 'APPROVED' if isApproved else 'REJECTED'
    try:
        # Get task token from DynamoDB
        response = table.get_item(
            Key={
                'approverId': approverId,
                'documentId': documentId
            }
        )
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
                },
                'body': json.dumps({'message': 'Document not found'})
            }
        

        table.update_item(
            Key={
                'approverId': approverId,
                'documentId': documentId
            },
            UpdateExpression='SET #status = :approved, #message = :message',
            ExpressionAttributeNames={
                '#status': 'status',
                '#message': 'message'
            },
            ExpressionAttributeValues={
                ':approved': status,
                ':message': message
            }
        )
        if isApproved:
            sfn.send_task_success(
                taskToken=response['Item']['taskToken'],
                output=json.dumps({
                    'approverId': approverId,
                    'documentId': documentId,
                    'status': status,
                    'message': message
                })
            )
        else :
            sfn.send_task_failure(
                taskToken=response['Item']['taskToken'],
                error='DocumentApprovalError',
                cause=json.dumps({
                    'approverId': approverId,
                    'documentId': documentId,
                    'status': status,
                    'message': message
                })
            )


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

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
        },
        'body': json.dumps({'message': 'Document approved successfully'})
    }