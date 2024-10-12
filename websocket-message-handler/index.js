// AWS Lambda function
exports.handler = async (event) => {
    // Log the incoming event
    console.log('Jeremy Received event:', JSON.stringify(event, null, 2));

    // Response structure for Lambda
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from Lambda!',
            input: event
        }),
    };
};