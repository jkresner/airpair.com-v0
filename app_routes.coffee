auth = require './lib/auth/base'
api_users = require './lib/api/users'
authz = require './lib/auth/ensureLoggedIn'

module.exports = (app) ->

  app.get     '/', (req, r) -> r.sendfile './public/index.html'
  app.get     '/about', (req, r) -> r.sendfile './public/index.html'

  app.get     '/login', (req, r) -> r.sendfile './public/login.html'
  app.get     '/dashboard', authz('/login'), (req, r) -> r.sendfile './public/dashboard.html'

  app.get     '/review', (req, r) -> r.sendfile './public/review.html'
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
  require('./lib/api/skills')(app)
  require('./lib/api/devs')(app)
  require('./lib/api/requests')(app)

  app.get     '/auth/github', auth.github.connect
  app.get     '/auth/github/callback', auth.github.connect, auth.github.done
  app.get     '/auth/google', auth.google.connect
  app.get     '/auth/google/callback', auth.google.connect, auth.google.done
  app.get     '/auth/twitter', auth.twitter.connect
  app.get     '/auth/twitter/callback', auth.twitter.connect, auth.twitter.done
  app.get     '/auth/linkedin', auth.linkedin.connect
  app.get     '/auth/linkedin/callback', auth.linkedin.connect, auth.linkedin.done

  app.get     '/logout', auth.logout