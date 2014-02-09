mongoose = require 'mongoose'

ApiConfig = require('../lib/models/ApiConfig')

configs = [
  {
    user: 'team@airpair.com',
    name: 'googleapi',
    data:
      tokens:
        refresh_token: '1/g6UgiRz90-E2T_rS1gxivGnO3drqb11sri_1WOqHwr8'
      discover:
        'calendar': 'v3'
        'youtube': 'v3'
  }
  {
    user: 'experts@airpair.com',
    name: 'googleapi',
    data:
      tokens:
        refresh_token: '1/NDqeY5kn4DdpWtuHQU-hMPzvlmVMiB8tWgb8LOc8uNY'
      discover:
        'calendar': 'v3'
        'youtube': 'v3'
  }
  {
    user: 'jk@airpair.com'
    name: 'googleapi',
    data:
      tokens:
        refresh_token: '1/U0PtEAcHs8D21uZw03M1UYXIPWarCw1eKSkzWp1FgsE'
      discover:
        'calendar': 'v3'
        'youtube': 'v3'
  }
  {
    user: 'jkresner@gmail.com'
    name: 'googleapi',
    data:
      tokens:
        refresh_token: '1/TsxKiF5VyiLIS6sLpR1PsXKv-Y0ATk_3ZTqN8tQrfXw'
      discover:
        'calendar': 'v3'
        'youtube': 'v3'
  }
]

# drop the collection
mongoose.connect process.env.MONGO_URI || "mongodb://localhost/airpair_dev"

mongoose.connection.once 'open', ->
  coll = mongoose.connection.collections[ApiConfig.collection.name]

  console.log 'opened'

  coll.drop (err) ->
    if err && err.message != 'ns not found'
      return console.log err.stack
    console.log 'collection dropped'

    console.log 'inserting...\n', configs

    # insert the docs
    numDone = 0
    configs.map (c, i) ->
      new ApiConfig(c).save (err) =>
        if err then console.log err.stack

        console.log "##{i+1} of #{configs.length} done"
        numDone++
        if numDone == configs.length then console.log 'FIN'
