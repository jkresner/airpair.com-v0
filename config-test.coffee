{config} = require './config'

# include watch (build) test directory
config.paths = watched: ['app','vendor', 'test']

config.db = "airpair_test"

config.env.mode = 'test'
config.server.port = 4444

config.plugins =
  autoReload:
    port: 4434

process.env.Payment_Env = 'test'

exports.config = config
