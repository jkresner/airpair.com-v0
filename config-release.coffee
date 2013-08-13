{config} = require './config'

# do not watch (build) test directory
config.paths =
  watched: ['app','vendor']


config.server.port = 5000

config.env.mode = 'prod'

exports.config = config