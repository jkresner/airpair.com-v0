global.isProd = process.env.MONGOHQ_URL?
console.log "in app node file", process.cwd(), 'isProd', isProd

require './lib/util/global'
winston       = require 'winston'   # logging
require './lib/util/winstonConfig'
mongoose      = require 'mongoose'
express       = require 'express'
passport      = require 'passport'


if isProd
  winston.error "ap restart"
  global.cfg = require('./config-release').config


app = express()


app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: 'airpair, the future' }

  if cfg.env.mode is 'test'
    app.use require('./test/server/test-passport').initialize()
  else
    app.use passport.initialize()

  app.use passport.session()

  app.use (error, req, res, next) ->
    console.log "handleError", error
    winston.error "error {req.url}", error
    res.status(500).sendfile "./public/500.html"


mongoUri = process.env.MONGOHQ_URL || "mongodb://localhost/#{cfg.db}"

mongoose.connect mongoUri

db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  console.log "connected to db #{cfg.db}"


require('./app_routes')(app)



exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  console.log "started on port: #{p}, path #{path}"
  app.listen p

if isProd
  exports.startServer()
