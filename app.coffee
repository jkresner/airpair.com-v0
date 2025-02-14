require 'colors'
console.log "--- In app file: ".yellow, process.cwd()
process.env.Env = brunch.env if !process.env.Env? && brunch?

require './lib/util/globals'
express          = require 'express'
# expressValidator = require 'express-validator'
# passport         = require 'passport'
# inspect          = require('util').inspect

# console.log 'config: ', inspect(config, depth: null).white

# setup our express app
app = express()

# load our db
mongoSessionStore = require('./app_mongoose')(express)

# consolidate      = require('consolidate')

hbs = require('hbs')
hbsHelpers = require './lib/util/hbsHelpers'
hbsHelpers.register hbs
hbs.registerPartials __dirname + '/app/partials'
# hbs.registerPartials __dirname + '/app/partials/airconf'
# hbs.registerPartials __dirname + '/app/scripts/shared/templates'

app.engine 'html', hbs.__express
# app.engine 'jade', consolidate.jade
app.set 'views', __dirname + '/public'
app.set 'view engine', 'hbs'

app.use express.compress() # gzip
app.use express.static(__dirname + '/public')
app.use express.json()
app.use express.urlencoded()
# app.use expressValidator() # must be immediately after express.bodyParser()!
app.use express.cookieParser()
app.use express.session
  cookie : { httpOnly: true, maxAge: 2419200000 }
  secret: if process.env.SESSION_SECRET? then process.env.SESSION_SECRET else 'airpair'
  store: mongoSessionStore
  name: 'aps'

# app.use (req, r, next) ->
#   # cookie-ize incoming referrer params
#   for param in ['utm_source', 'utm_medium', 'utm_term', 'utm_content', 'utm_campaign']
#     if req.query[param]
#       r.cookie param, req.query[param]
#   next()

# if config.env is 'test'
#   require('./app_test')(app)
# else
#   app.use passport.initialize()

# app.use passport.session()

require('./routes/app')(app)

if config.env is 'test'
  require('./routes/test')(app)

app.use (err, req, res, next) ->
  # str = (err and err.stack) or inspect err, {depth: 20}
  userInfo = "anonymous"
  if req.user
    goog = req.user.google
    userInfo = req.user._id + ' ' + goog._json.email + ' ' + goog.displayName

  console.log "handleError #{userInfo} #{req.method} #{req.url} #{str}"
  winston.error "handleError #{userInfo} #{req.method} #{req.url} #{str}" if config.isProd
  res.status(500).sendfile "./public/500.html"

process.on 'uncaughtException', (err) ->
  console.log "uncaughtException #{err.stack}"
  winston.error "uncaughtException #{err.stack}" if config.isProd
  process.exit 1

# exports.startServer is called automatically in brunch watch mode, but needs invoking in normal node
exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  $log "--- starting on port: #{p}, path #{path}".yellow
  app.listen p

if config.isProd || !module.parent
  exports.startServer()


