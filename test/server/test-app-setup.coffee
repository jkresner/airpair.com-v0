process.env.Env = 'test'
console.log "--------------------------------------------------------"
console.log "In app TEST file", process.cwd(), 'isTest', true
console.log "--------------------------------------------------------"

require './../../lib/util/appConfig'
require './../../lib/util/globals'

express      = require 'express'
passport     = require 'passport'
passportMock = require './test-passport'


app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()

  app.use express.session secret: 'testing is the future'

  # app.use passport.initialize()
  app.use passportMock.initialize(app)
  app.use passport.session()

data = require './../data/all'

module.exports = {app,data,passportMock}
