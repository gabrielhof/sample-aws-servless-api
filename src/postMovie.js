const AWS = require('aws-sdk');
const uuid = require('uuid');

const dynamoDb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const movie = {
        id: uuid.v4(),
        ...JSON.parse(event.body)
    };
    
    await dynamoDb.put({
        TableName: 'MovieCollection',
        Item: movie
    }).promise();
    
    return {
        body: JSON.stringify(movie)
    };
};
