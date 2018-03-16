_getEndpointFromBucket: (bucket) ->
  if @_daxEndpoints[bucket]?
    @_daxEndpoints[bucket]
  else
    @_cluster

# *****************************

if process.env.ENV is 'test'
  AWSmock = require 'aws-sdk-mock'
  AWSmock.mock 'DynamoDB', 'putItem', (params, callback) ->
    cache.put 'dynamoMock-' + params.Item._id.S, params
    callback(null, 'successfully put item in database')
  AWSmock.mock 'DynamoDB', 'getItem', (params, callback) ->
    callback(null, cache.get('dynamoMock-' + params.Key._id.S))

#  ****************************

set = (method, params, value, opts, cb) ->
    if typeof opts is 'function'
      cb = opts
      opts = {}
    { bucket, key, opts, callback } = @_params method, params, opts, cb
    params =
      Item:
        '_id':
          S: key
        'value':
          S: JSON.stringify(value)
      TableName: bucket
    @cluster.putItem params, (err, res) =>
      if err?
        @_error method, "set", key, opts, value

      callback err, res

# *****************************

_params: (keyMethod, keyParams, options, callback) ->
  keyMethod =  @_resolveMethod keyMethod