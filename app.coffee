console.log "--------------------------------------------------------"
console.log "In app file: ", process.cwd()

require './lib/util/appConfig'
require './lib/util/globals'
express       = require 'express'
passport      = require 'passport'
inspect       = require('util').inspect
expressValidator = require 'express-validator'
partials      = require './partials'

# setup our express app
app = express()

# load our db
{MongoSessionStore} = require('./app_mongoose')(app, express)
mongoSessionStore = new MongoSessionStore url: "#{cfg.mongoUri}/sessions"

app.engine('html', require('hbs').__express)
app.set('view engine', 'hbs')
app.set('views', __dirname + '/public')

partials.register()

app.use express.compress() # gzip
app.use express.static(__dirname + '/public')
app.use express.bodyParser()
app.use expressValidator() # must be immediately after express.bodyParser()!
app.use express.cookieParser()
app.use express.session
  cookie : { path: '/', httpOnly: true, maxAge: 2419200000 }
  secret: 'airpair the future'
  store: mongoSessionStore

app.use (req, r, next) ->
  # cookie-ize incoming referrer params
  for param in ['utm_source', 'utm_medium', 'utm_term', 'utm_content', 'utm_campaign']
    if req.query[param]
      r.cookie param, req.query[param]
  next()

if cfg.env is 'test'
  require('./app_test')(app)
else
  app.use passport.initialize()

app.use passport.session()

require('./app_routes')(app)

if cfg.env is 'test'
  require('./app_test_routes')(app)

app.use (err, req, res, next) ->
  str = (err and err.stack) or inspect err, {depth: 20}
  console.log "handleError #{req.url} #{str}"
  winston.error "handleError #{req.url} #{str}" if cfg.isProd
  res.status(500).sendfile "./public/500.html"

process.on 'uncaughtException', (err) ->
  console.log "uncaughtException #{err.stack}"
  winston.error "uncaughtException #{err.stack}" if cfg.isProd
  process.exit 1

# exports.startServer is called automatically in brunch watch mode, but needs invoking in normal node
exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  $log "started on port: #{p}, path #{path}"
  app.listen p

if cfg.isProd || !module.parent
  exports.startServer()
