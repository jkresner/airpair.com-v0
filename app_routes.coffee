
api_users = require './lib/api/users'
authz = require './lib/auth/ensureLoggedIn'

module.exports = (app) ->

  app.get     '/', (req, r) -> r.sendfile './public/index.html'
  app.get     '/about', (req, r) -> r.sendfile './public/index.html'

  app.get     '/login', (req, r) -> r.sendfile './public/login.html'
  app.get     '/dashboard', authz('/login'), (req, r) -> r.sendfile './public/dashboard.html'
  app.get     '/review', authz('/login'), (req, r) -> r.sendfile './public/review.html'

  app.get     '/be-an-expert', (req, r) -> r.sendfile './public/beexpert.html'
  app.get     '/traction', (req, r) -> r.sendfile './public/traction.html'

  app.get     '/find-an-expert', (req, r) -> r.sendfile './public/request.html'

  app.get     '/welcome-expert', (req, r) -> r.sendfile './public/welcomeexpert.html'
  app.get     '/welcome-padawan', (req, r) -> r.sendfile './public/welcomestudent.html'

  app.get     '/edu/tags', (req, r) -> r.sendfile './public/edu/tags.html'
  app.get     '/adminn', authz('/'), (req, r) -> r.sendfile './public/admin.html'

  app.get     '/api/users/me', api_users.detail

  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)

  require('./lib/auth/base')(app)