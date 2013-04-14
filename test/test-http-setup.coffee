global.mongoose = require 'mongoose'
global.request = require 'supertest'
global.express = require 'express'
passport = require 'passport'

global.app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()

  app.use express.session { secret: 'airpair is the future' }
  app.use passport.initialize()
  app.use passport.session()
