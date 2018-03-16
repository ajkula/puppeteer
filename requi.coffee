AWS = require 'aws-sdk'
if process.env.ENV is 'test'
  AWSmock = require 'aws-sdk-mock'
  AWSmock.mock 'DynamoDB', 'putItem', (params, callback) ->
    cache.put 'dynamoMock-' + params.Item._id.S, params
    callback(null, 'successfully put item in database')
  AWSmock.mock 'DynamoDB', 'getItem', (params, callback) ->
    callback(null, cache.get('dynamoMock-' + params.Key._id.S))