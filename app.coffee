console.log "--------------------------------------------------------"
console.log "In app file: ", process.cwd()

require './lib/util/appConfig'
require './lib/util/globals'
express       = require 'express'
passport      = require 'passport'

# setup our express app
app = express()

# load our db
{MongoSessionStore} = require('./app_mongoose')(app, express)
mongoSessionStore = new MongoSessionStore url: "#{cfg.mongoUri}/sessions"

app.engine('html', require('hbs').__express)
app.set('view engine', 'hbs')
app.set('views', __dirname + '/public')

app.use express.static(__dirname + '/public')
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  cookie : { path: '/', httpOnly: true, maxAge: 2419200000 }
  secret: 'airpair the future'
  store: mongoSessionStore

$log 'still going before utm middleware'

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

$log 'still going before app_test_routes'

require('./app_routes')(app)

if cfg.env is 'test'
  require('./app_test_routes')(app)

app.use (err, req, res, next) ->
  console.log "handleError", err
  winston.error "error #{req.url}", err if cfg.isProd
  res.status(500).sendfile "./public/500.html"

# exports.startServer is called automatically in brunch watch mode, but needs invoking in normal node
exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  $log "started on port: #{p}, path #{path}"
  app.listen p

if cfg.isProd
  exports.startServer()