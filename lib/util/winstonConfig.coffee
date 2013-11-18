winstonses  =   require('winston-ses').Ses


winston.remove winston.transports.Console


logFileConfig =
  filename:       'airpair-express.log'
  timestamps:     true
  level:          'error' # process.env.AP_FILE_LOG_LEVEL || 'info'
  json:           false

winston.add winston.transports.Console, logConsoleConfig


logConsoleConfig =
  level:          'error' # process.env.AP_CONSOLE_LOG_LEVEL || 'info'
  timestamp:      true
  #colorize:      not cfg.isProd

winston.add winston.transports.File, logFileConfig


logEmailConfig =
  level:          'error'
  sesAccessKey:   process.env.AP_SES_ACCESS_KEY
  sesSecretKey:   process.env.AP_SES_SECRET_KEY
  sesFrom:        'airpair <jk@airpair.com>'
  sesTo:          ['airpair <jk@airpair.com>', 'dtrejo <dt@airpair.com>']
  sesSubject:     'ap error'


winston.add(winstonses, logEmailConfig) if cfg.isProd
