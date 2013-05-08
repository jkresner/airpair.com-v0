global.mongoose = require 'mongoose'
global.request = require 'supertest'
global.express = require 'express'
global.und = require 'underscore'
passport = require 'passport'
passportMock = require './test-passport'



global.app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()

  app.use express.session { secret: 'airpair is the future' }

  # app.use passport.initialize()
  app.use passportMock.initialize()
  app.use passport.session()