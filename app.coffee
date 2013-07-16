require './lib/util/globals'

$log "--------------------------------------------------------"
$log "In app file", process.cwd(), 'isProd', isProd

express       = require 'express'
passport      = require 'passport'

if isProd
  winston.error "ap restart"
  global.cfg = require('./config-release').config

# setup our express app
app = express()

# load our db
{MongoSessionStore} = require('./app_mongoose')(app, express)
mongoSessionStore = new MongoSessionStore url: "#{app.get('mongoUri')}/sessions"

app.set('view engine', 'hbs')
app.engine('html', require('hbs').__express)
app.set('views', __dirname + '/public')

app.use express.static(__dirname + '/public')
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  cookie : { path: '/', httpOnly: true, maxAge: 2419200000 }
  secret: 'airpair the future'
  store: mongoSessionStore

if cfg.env.mode is 'test'
  require('./app_test')(app)
else
  app.use passport.initialize()

app.use passport.session()

# custom middleware
app.use (req, r, next) ->
  # cookie-ize incoming referrer params
  for param in ['utm_source', 'utm_medium', 'utm_term', 'utm_content', 'utm_campaign']
    if req.query[param]
      r.cookie param, req.query[param]
  next()

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