require './lib/util/globals'

$log "in app file", process.cwd(), 'isProd', isProd

express       = require 'express'
passport      = require 'passport'

if isProd
  winston.error "ap restart"
  global.cfg = require('./config-release').config

# setup our express app
app = express()

# load our db
{MongoSessionStore} = require('./app_mongoose')(app, express)

app.use express.static(__dirname + '/public')
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  cookie : { path: '/', httpOnly: true, maxAge: 2419200000 }
  secret: 'airpair the future'
  store: new MongoSessionStore url: "#{app.get('mongoUri')}/sessions"

if cfg.env.mode is 'test'
  require('./app_test')(app)
else
  app.use passport.initialize()

app.use passport.session()
app.use passport.authenticate('remember-me')

require('./app_routes')(app)


app.use (err, req, res, next) ->
  console.log "handleError", err
  winston.error "error #{req.url}", err if isProd
  res.status(500).sendfile "./public/500.html"


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  console.log "started on port: #{p}, path #{path}"
  app.listen p

if isProd
  exports.startServer()