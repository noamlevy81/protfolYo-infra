import base64
import json

import boto3


def handler(event, context):
    body = event['body']
    content = json.loads(body)
    base64_zip_file = content['base64']
    zip_file_name = content['file_name']
    user_name = content['user_name']
    s3_client = boto3.client('s3')
    try:

        with open(f"/tmp/{zip_file_name}", "wb") as f:
            decoded = base64.b64decode(base64_zip_file)
            f.write(decoded)

        s3_client.upload_file(f"/tmp/{zip_file_name}", "nl-bucket-test", f"{user_name}/{zip_file_name}")

        return {
            'statusCode': 200,
            'body': f"{zip_file_name} uploaded successfully"
        }

    except Exception as e:

        return {'statusCode': 500,
                'body': e
                }



