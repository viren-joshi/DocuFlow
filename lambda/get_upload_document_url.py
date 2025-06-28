import json
import os
import boto3
import uuid

s3 = boto3.client('s3')
s3_bucket = os.environ.get('S3_BUCKET')

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}')) if 'body' in event else {}
    isNew = body.get('is_new', True)
    file_name = body.get('file_name')
    uuid_str = str(uuid.uuid4())

    if not file_name:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps({'message': 'file_name is required'})
        }
    complete_filename = f"documents/{file_name}_{uuid_str}" if isNew else file_name
    try:
        s3_response = s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': s3_bucket, 'Key': complete_filename, "ContentType": "application/pdf"},
            ExpiresIn=3600
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
        'body': json.dumps({'url': s3_response, "file_name": complete_filename})
    }