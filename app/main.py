def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": "{\"message\": \"The backend is working\"}"
    }
