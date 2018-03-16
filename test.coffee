_ = require 'underscore'
cache = require 'memory-cache'
https = require 'https'

AWS = require 'aws-sdk'
if process.env.ENV is 'test'
  AWSmock = require 'aws-sdk-mock'
  AWSmock.mock 'DynamoDB', 'putItem', (params, callback) ->
    cache.put 'dynamoMock-' + params.Item._id.S, params
    callback(null, 'successfully put item in database')
  AWSmock.mock 'DynamoDB', 'getItem', (params, callback) ->
    callback(null, cache.get('dynamoMock-' + params.Key._id.S))

Util = require '../utils/util'
metrics = require '../utils/metrics'
config = require('../utils/configurator')

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

  get: (method, params, opts, cb) ->
    { bucket, key, opts, callback } = @_params method, params, opts, cb
    delete opts.expiry

    init_time = Date.now()
    _compute_get = (err, res) =>
      metrics.save("dynamo.#{bucket}.get", Date.now() - init_time)
      @_error method, "get", key, opts if err?

      # Put the result into the cache
      unless err?
        if opts.cache and opts.cache.type is 'global'
          cache_item = if res? then res else -1

          # ###########################################
          # Temporary optim for checking geo targeting
          # ###########################################
          if key.startsWith('cm:') and typeof cache_item is 'object' and cache_item['value']['geo_targeting']?
            cache_item['value']['geo_automat'] = {}

            if cache_item['value']['geo_targeting'].length is 0
              cache_item['value']['geo_automat']['allow'] = true
            else
              targeting = cache_item['value']['geo_targeting'].toLowerCase().split(',')
              allow = _(targeting)
                .filter (t) -> t.substr(0, 5) is 'allow'
                .map (t) -> t.slice(6).split(':')
              deny = _(targeting)
                .filter (t) -> t.substr(0, 4) is 'deny'
                .map (t) -> t.slice(5).split(':')
              calculate_automat = (target) ->
                automat = null
                for a in target
                  unless automat?
                    automat = if a[0] is 'all' then true else {}
                  continue if a[0] is 'all'
                  unless automat[a[0]]?
                    automat[a[0]] = if a[1] is 'all' then true else {}
                  continue if a[1] is 'all' or automat[a[0]] is true
                  unless automat[a[0]][a[1]]?
                    automat[a[0]][a[1]] = if a[2] is 'all' then true else {}
                  continue if a[2] is 'all' or automat[a[0]][a[1]] is true
                  automat[a[0]][a[1]][a[2]] = true
                automat
              cache_item['value']['geo_automat']['allow'] = calculate_automat(allow)
              cache_item['value']['geo_automat']['deny'] = calculate_automat(deny)
          # ###########################################

          cache.put "dynamo-#{key}", cache_item, opts.cache.expiry

      callback err, res

    params =
      Key:
        '_id':
          S: key
      TableName: bucket
      ProjectionExpression: '#value'
      ExpressionAttributeNames:
        '#value': 'value'
    # Try to get value from cache
    if opts.cache and opts.cache.type is 'global'
      result = cache.get "dynamo-#{key}"
      if result
        return callback null, if result is -1 then null else result
      else
        @cluster.getItem params, _compute_get
    else
      @cluster.getItem params, _compute_get

#  del: (method, params, opts, cb) ->
#    { bucket, key, opts, callback } = @_params method, params, opts, cb
#    bucket.remove key, opts, (err, res) =>
#      @_error method, "del", key, opts if err? and err.code is not 13
#
#      # Remove the stored value in the cache
#      if !err and opts.cache and opts.cache.type is 'global'
#        cache.del "dynamo-#{key}"
#
#      callback err, res

  set: (method, params, value, opts, cb) ->
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

#  incr: (method, params, optional..., cb) ->
#    # optional = [[value]]
#    { bucket, key, opts, callback } = @_params method, params, null, cb
#
#    value = if optional.length > 0 then optional[0] else 1
#    if value?
#      opts.initial = value
#
#    bucket.counter key, value, opts, (err, res) =>
#      @_error method, "incr", key, opts if err? and err.code is not 13
#      callback err, res

  _error: (ogury_method, method, key, opts, err, value = "") ->
    console.error "Dynamo Error: met=%s, op=%s, k=%s, opt=%j, val=%j, err=%j"
    , ogury_method, method, key, opts, value, err

  _keys: null
  keys: ->
    @_keys = require '../utils/keys' unless @_keys
    return @_keys

  _wrap: (callback) ->
    callback = Util.resolveFunc callback
    return (err, results) ->
      if err
        callback err, null
      else
        if results?.Item?.value?.S?
          callback null, JSON.parse(results.Item.value.S)
        else
          callback null, null

  _resolveMethod: (method) ->
    method = method.charAt(0).toUpperCase() + method.slice(1)
    "for#{method}"

  _params: (keyMethod, keyParams, options, callback) ->
    keyMethod =  @_resolveMethod keyMethod

    unless @keys()[keyMethod]
      throw new Error "#{keyMethod} isn't defined in Keys"

    { bucket, key, opts } = @keys()[keyMethod].apply @, keyParams
    env = if process.env.ENV is 'production' then 'prod' else process.env.ENV
    bucket = bucket + '-' + env
    options = {} unless options
    if typeof options is 'function'
      callback = options
      options = {}
    opts = _.extend opts, options
    callback = @_wrap callback
    return { bucket, key, opts, callback }

module.exports = new DynamoUtil()
