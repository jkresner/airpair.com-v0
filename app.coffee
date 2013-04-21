global.$log = console.log
$log "in app node file", process.cwd()

require('./lib/bootstrap/clean')
require('./lib/bootstrap/tags')()


mongoose = require 'mongoose'
express = require 'express'
passport = require 'passport'

app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: 'airpair is the future' }
  # app.use passport.initialize()
  app.use require('./test/server/test-passport').initialize(require('./test/data/users')[0])
  app.use passport.session()


global.isProd = process.env.MONGOHQ_URL?

mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/airpair_dev'

mongoose.connect mongoUri

db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  console.log 'connected to db airpair_dev'


require('./app_routes')(app)


# Tag = require './../models/tag'
# Tag.find({}).remove()


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  console.log "startServer on port: #{p}, path #{path}"
  app.listen p


if isProd
  exports.startServer()