{config} = require './config'

# do not watch (build) test directory
config.paths =
  watched: ['app','vendor']


config.server.port = 5000

config.env.mode = 'prod'

config.analytics.mixpanel.id: '076cac7a822e2ca5422c38f8ab327d62'

exports.config = config