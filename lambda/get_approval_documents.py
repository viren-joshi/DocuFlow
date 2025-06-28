import boto3
import json
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

cognito = boto3.client('cognito-idp')
user_pool_id = os.environ.get('USER_POOL_ID')


gsi_index = os.environ.get('APPROVER_INDEX_GSI') 

def get_email_from_user_id(user_id):
    try:
        resp = cognito.list_users(
            UserPoolId=user_pool_id,
            Filter=f"sub = \"{user_id}\""
        )
        if resp['Users']:
            return next((attr['Value'] for attr in resp['Users'][0]['Attributes'] if attr['Name'] == 'email'), user_id)
    except Exception as e:
        print(f"Failed to lookup user {user_id}: {str(e)}")
    return user_id

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}')) if 'body' in event else {}
    approver_id = body.get('approver_id')

    if not approver_id:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
                },
            'body': json.dumps({'message': 'approver_id is required'})
        }
    try:
        response = table.query(
            IndexName = gsi_index,
            KeyConditionExpression=boto3.dynamodb.conditions.Key('approverId').eq(approver_id),
        )
        documents = response.get('Items', [])
        
        if not documents:
            return {
                'statusCode': 200,
                'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
                },
                'body': json.dumps({'message': 'No documents found for this approver', 'documents': []})
            }
        
        data = []
        for document in documents:
            temp = document
            temp["submittedBy"] = get_email_from_user_id(temp["submittedBy"])
            data.append(temp)

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
                },
            'body': json.dumps({'documents': data, "message": "Success"})
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