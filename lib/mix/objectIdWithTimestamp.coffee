{ObjectId} = require('mongoose').Schema.Types

# http://stackoverflow.com/questions/8749971/can-i-query-mongodb-objectid-by-date

module.exports = ObjectIdWithTimestamp = (timestamp) ->
  # Convert date object to hex seconds since Unix epoch
  hexSeconds = Math.floor(timestamp/1000).toString(16)

  # Create an ObjectId with that hex timestamp
  new ObjectId(hexSeconds + "0000000000000000").path


