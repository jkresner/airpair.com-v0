log = require 'winston'

logFileConfig =
  filename: 'airpair-express.log'
  timestamps: true
  level: process.env.AP_FILE_LOG_LEVEL || 'info'
  json: false

logConsoleConfig =
  level: process.env.AP_CONSOLE_LOG_LEVEL || 'info'
  colorize: not isProd
  timestamp: true

logEmailConfig =
  level: 'error'
  sesAccessKey: process.env.AP_SES_ACCESS_KEY
  sesSecretKey: process.env.AP_SES_SECRET_KEY
  sesFrom: 'airpair <jk@airpair.com>'
  sesTo: 'airpair <jk@airpair.com>'
  sesSubject: 'ap error'

log.remove log.transports.Console
log.add log.transports.Console, logConsoleConfig
log.add log.transports.File, logFileConfig
log.add(require('winston-ses').Ses, logEmailConfig) if isProd