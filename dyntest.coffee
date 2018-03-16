AWS = require 'aws-sdk'
if process.env.ENV is 'test'
  AWSmock = require 'aws-sdk-mock'
  AWSmock.mock 'DynamoDB', 'putItem', (params, callback) ->
    cache.put 'dynamoMock-' + params.Item._id.S, params
    callback(null, 'successfully put item in database')
  AWSmock.mock 'DynamoDB', 'getItem', (params, callback) ->
    callback(null, cache.get('dynamoMock-' + params.Key._id.S))


#  *****************************************************************

class DynamoUtil

  constructor: ->
    @cluster = new AWS.DynamoDB
      accessKeyId: if config.AWS_ACCESS_KEY_ID?.length then config.AWS_ACCESS_KEY_ID else undefined
      secretAccessKey: if config.AWS_SECRET_ACCESS_KEY?.length then config.AWS_SECRET_ACCESS_KEY else undefined
      region: if config.AWS_REGION?.length then config.AWS_REGION else undefined
      apiVersion: '2012-08-10'
      httpOptions:
        agent: new https.Agent({rejectUnauthorized: true, keepAlive: true})
    @flush()

  flush: ->
    cache.clear()


#  *****************************************************************

class DynamoUtil
 	 
   constructor: ->	   constructor: ->
      @_daxEndpoints = {}
      if config.DAX_ENDPOINT_DATA?.length
        console.log "DAX configured at #{config.DAX_ENDPOINT_DATA} for table data-#{process.env.CHEF_ENV}"
        @_daxEndpoints["data-#{process.env.CHEF_ENV}"] = new AmazonDaxClient
          endpoints: [config.DAX_ENDPOINT_DATA]
          region: if config.AWS_REGION?.length then config.AWS_REGION else undefined
  
      @_cluster = new AWS.DynamoDB

#  *****************************************************************
