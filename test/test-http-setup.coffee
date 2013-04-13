global.mongoose = require 'mongoose'
global.request = require 'supertest'
global.express = require 'express'

global.app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()