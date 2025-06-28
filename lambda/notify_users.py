import json
import os
import boto3
import resend

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

resend.api_key = os.environ.get('RESEND_API_KEY')

def send_notification(approver_email):
    # Code to send notifications to the approvers. SES or other email services can be userd here.
    try:
        params : resend.Emails.SendParams = {
            "from" : "Docuflow <docuflow-notifications@resend.dev>",
            "to" : ["viren.joshi.ca@gmail.com"],
            "subject" : "You have a document to approve!",
            "html" : "<p>Please review and approve the document.</p>"
        }
        email = resend.Emails.send(params)
        print(f"Email sent successfully: {email}")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
        raise e
    

def lambda_handler(event, context):
    approver_id = event.get('approver')
    document_id = event.get('documentId')
    approver_email = event.get('approverEmail')

    if not approver_id or not document_id:
        return {
            'statusCode': 400,  
            'body': json.dumps({'message': 'approver and documentId are required'})
        }
    else:
        send_notification(approver_email)
        # Update the taskToken in DynamoDB
        try:
            table.update_item(
                Key={
                    'approverId': approver_id,
                    'documentId': document_id
                },
                UpdateExpression='SET taskToken = :taskToken',
                ExpressionAttributeValues={
                    ':taskToken': event.get('taskToken')
                }
            )
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps({'message': str(e)})
            }
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Notification sent successfully'})
    }