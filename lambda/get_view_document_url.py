import json
import os
import boto3

s3 = boto3.client('s3')
s3_bucket = os.environ.get('S3_BUCKET')


def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}')) if 'body' in event else {}
    file_name = body.get('file_name') # Should be `fileName_uuid` format

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

    try:
        s3_response = s3.generate_presigned_url('get_object', Params={'Bucket': s3_bucket, 'Key': file_name}, ExpiresIn=3600)
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
        'body': json.dumps({'url': s3_response})
    }