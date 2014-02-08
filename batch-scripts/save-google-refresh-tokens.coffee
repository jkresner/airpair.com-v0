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
]

# drop the collection
mongoose.connect "mongodb://localhost/airpair_dev"

mongoose.connection.once 'open', ->
  coll = mongoose.connection.collections[ApiConfig.collection.name]

  console.log 'opened'

  coll.drop (err) ->
    if err && err.message != 'ns not found'
      return console.log err.stack
    console.log 'collection dropped'

    console.log 'inserting...\n', configs

    # insert the docs
    configs.map (c, i) ->
      new ApiConfig(c).save =>
        console.log "##{i} of #{configs.length-1} done"
        if i == configs.length - 1 then console.log 'FIN'
