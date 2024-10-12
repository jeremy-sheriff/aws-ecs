# index.py
import json

def handler(event, context):
    # Log the event to see what the WebSocket message looks like
    print(f"Received event: {json.dumps(event)}")

    # You can access the message from the event body
    message = json.loads(event.get('body', '{}')).get('message', 'No message sent')

    # Response to the client
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f"Message received: {message}"
        })
    }
