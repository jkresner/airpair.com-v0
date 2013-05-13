{config} = require './config'

config.db = "airpair_test"

config.env.mode = 'test'
config.server.port = 4444

config.plugins =
  autoReload:
    port: 4434

exports.config = config
