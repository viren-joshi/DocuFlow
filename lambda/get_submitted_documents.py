import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
gsi_index = os.environ.get('SUBMITTED_INDEX_GSI')  # Assuming you have a GSI for querying by user_id
table = dynamodb.Table(table_name)

cognito = boto3.client('cognito-idp')
user_pool_id = os.environ.get('USER_POOL_ID')

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
    user_id = body.get('user_id') # User ID of `submittedBy`
    if not user_id:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': 'user_id is required'})
        }
    
    try:
        response = table.query(
            IndexName = gsi_index,
            KeyConditionExpression=boto3.dynamodb.conditions.Key('submittedBy').eq(user_id),
        )

        data = response.get('Items', [])
        grouped_docs = {}
        for item in data:
            doc_id = item['documentId']
            approver_id = item['approverId']
            status = item['status']
            message = item['message']
            finalStatus = item['finalStatus']
            submitted_at = item.get('submittedAt', 'N/A')

            if doc_id not in grouped_docs:
                grouped_docs[doc_id] = {
                    'documentId': doc_id,
                    'approvers': [],
                    'submittedAt': submitted_at,
                    'finalStatus': finalStatus
                }
            grouped_docs[doc_id]['approvers'].append({
                "approverId" : approver_id,
                "approverEmail" : get_email_from_user_id(approver_id),
                "status" : status,
                "message" : message
            })

        # Flatten and enrich approvers with emails
        documents = []
        for doc in grouped_docs.values():
            documents.append({
                'documentId': doc['documentId'],
                'approvers': doc["approvers"],
                'submittedAt': doc['submittedAt'],
                'finalStatus' : doc["finalStatus"]
            })

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
            },
            'body': json.dumps({'documents': documents, "message": "Success"})
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