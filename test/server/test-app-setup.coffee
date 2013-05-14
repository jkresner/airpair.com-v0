require './../../lib/util/global'
express       = require 'express'
passport      = require 'passport'
passportMock  = require './test-passport'


app = express()

app.configure ->
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.cookieParser()

  app.use express.session secret: 'testing is the future'

  # app.use passport.initialize()
  app.use passportMock.initialize()
  app.use passport.session()

data =
  users: require './../data/users'
  requests: require './../data/requests'
  companys: require './../data/companys'
  experts: require './../data/experts'
  users: require './../data/users'

module.exports = {app,data,passportMock}