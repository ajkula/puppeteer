

const AWS = __TEST ? require('aws-sdk-mock') : require('aws-sdk')

if (process.env.ENV === 'test') {
  AWSmock.mock('DynamoDB', 'putItem', function(params, callback) {
    cache.put('dynamoMock-' + params.Item._id.S, params);
    return callback(null, 'successfully put item in database');
  });
  AWSmock.mock('DynamoDB', 'getItem', function(params, callback) {
    return callback(null, cache.get('dynamoMock-' + params.Key._id.S));
  });
}

const couchbase = __TEST ? require('couchbase').Mock : require('couchbase')
const cluster = __TEST ? new couchbase.Cluster() : new couchbase.Cluster(`couchbase://${config.COUCHBASE_HOST}`)
