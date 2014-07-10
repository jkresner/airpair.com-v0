require 'colors'
console.log "--- In app file: ".yellow, process.cwd()
process.env.Env = brunch.env if !process.env.Env? && brunch?

require './lib/util/globals'
express          = require 'express'
expressValidator = require 'express-validator'
passport         = require 'passport'
inspect          = require('util').inspect

console.log 'config: ', inspect(cfg, depth: null).white

# setup our express app
app = express()

# load our db
{MongoSessionStore} = require('./app_mongoose')(app, express)
storeOptions = url: "#{cfg.mongoUri}/sessions", auto_reconnect: true
mongoSessionStore = new MongoSessionStore storeOptions

hbs              = require('hbs')
hbsPartials      = require './lib/util/hbsPartials'
hbsHelpers       = require './lib/util/hbsHelpers'
app.set 'views', __dirname + '/public'
app.set 'view engine', 'hbs'
app.engine 'html', hbs.__express #allow html extension

# Eventually all global partials should be in '/app/partials'
hbsPartials.register __dirname, ['/app/partials','/app/scripts/shared/templates']
hbsHelpers.register hbs

app.use express.compress() # gzip
app.use express.static(__dirname + '/public')
app.use express.json()
app.use express.urlencoded()
app.use expressValidator() # must be immediately after express.bodyParser()!
app.use express.cookieParser()
app.use express.session
  cookie : { path: '/', httpOnly: true, maxAge: 2419200000 }
  secret: 'airpair the future'
  store: mongoSessionStore

# app.use (req, r, next) ->
#   # cookie-ize incoming referrer params
#   for param in ['utm_source', 'utm_medium', 'utm_term', 'utm_content', 'utm_campaign']
#     if req.query[param]
#       r.cookie param, req.query[param]
#   next()

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
  userInfo = "anonymous"
  if req.user
    goog = req.user.google
    userInfo = req.user._id + ' ' + goog._json.email + ' ' + goog.displayName

  console.log "handleError #{userInfo} #{req.url} #{str}"
  winston.error "handleError #{userInfo} #{req.url} #{str}" if cfg.isProd
  res.status(500).sendfile "./public/500.html"

process.on 'uncaughtException', (err) ->
  console.log "uncaughtException #{err.stack}"
  winston.error "uncaughtException #{err.stack}" if cfg.isProd
  process.exit 1

# exports.startServer is called automatically in brunch watch mode, but needs invoking in normal node
exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  $log "--- starting on port: #{p}, path #{path}".yellow
  app.listen p

if cfg.isProd || !module.parent
  exports.startServer()


