api_users = require './lib/api/users'
authz = require './lib/auth/authz/authz'

file = (r, file) -> r.sendfile "./public/#{file}.html"

module.exports = (app) ->

  # login / auth routes
  require('./lib/auth/base')(app)

  # pages
  app.get '/', (req, r) -> file r, 'index'
  app.get '/about', (req, r) -> file r, 'index'
  app.get '/login', (req, r) -> file r, 'login'
  app.get '/traction', (req, r) -> file r, 'traction'
  app.get '/be-an-expert', (req, r) -> file r, 'beexpert'
  app.get '/find-an-expert', (req, r) -> file r, 'request'

  app.get '/dashboard', authz.isLoggedIn('/login'),
    (req, r) -> file r, 'dashboard'
  app.get '/review', authz.isLoggedIn('/login'),
    (req, r) -> file r, 'review'

  # app.get '/adminn', authz('/'), (req, r) -> file r, 'admin.html'

  # api
  app.get '/api/users/me', api_users.detail
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)

  # todo, brush up page
  app.get '/edu/tags', (req, r) -> file r, 'edu/tags'


  # require('./lib/v0.3/api/requests')(app)