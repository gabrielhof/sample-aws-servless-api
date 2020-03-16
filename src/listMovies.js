const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const response = await dynamoDb.scan({
        TableName: 'MovieCollection'
    }).promise();
    
    return {
        statusCode: 200,
        body: JSON.stringify(response.Items)
    };
};
