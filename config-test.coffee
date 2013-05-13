{config} = require './config'

config.db = "airpair_test"

config.env.mode = 'test'
config.server.port = 4444
exports.config = config
