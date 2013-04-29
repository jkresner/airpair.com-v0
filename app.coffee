global.$log = console.log
global.und = require 'underscore'
$log "in app node file", process.cwd()


mongoose = require 'mongoose'
express = require 'express'
passport = require 'passport'

app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: 'airpair, the future' }

  if cfg.env.mode is 'test'
    app.use require('./test/server/test-passport').initialize(require('./test/data/users')[0])
  else
    app.use passport.initialize()

  app.use passport.session()


global.isProd = process.env.MONGOHQ_URL?

mongoUri = process.env.MONGOHQ_URL || "mongodb://localhost/#{cfg.db}"

mongoose.connect mongoUri

db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  console.log "connected to db #{cfg.db}"
  #require('./lib/bootstrap/run_v0.4')()



require('./app_routes')(app)


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  console.log "startServer on port: #{p}, path #{path}"
  app.listen p


if isProd
  exports.startServer()