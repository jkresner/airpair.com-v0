auth = require './lib/auth/base'
api_users = require './lib/api/users'
api_skills = require './lib/api/skills'
api_devs = require './lib/api/devs'
api_companys = require './lib/api/companys'
api_requests = require './lib/api/requests'
authz = require './lib/auth/ensureLoggedIn'

passport = require 'passport'

# ensureUnauthenticated = (req, res, next) ->
  # if req.isAuthenticated()
    # display an "already logged in" message
    # return res.redirect('/')
  # next()

module.exports = (app) ->

  app.get     '/', (req, r) -> r.sendfile './public/index.html'
  app.get     '/about', (req, r) -> r.sendfile './public/index.html'
  app.get     '/adminn', authz('/'), (req, r) -> r.sendfile './public/admin.html'
  app.get     '/review', (req, r) -> r.sendfile './public/review.html'
  app.get     '/be-an-expert', (req, r) -> r.sendfile './public/beexpert.html'
  app.get     '/traction', (req, r) -> r.sendfile './public/traction.html'

  app.get     '/find-an-expert', (req, r) -> r.sendfile './public/request.html'

  app.get     '/welcome-expert', (req, r) -> r.sendfile './public/welcomeexpert.html'
  app.get     '/welcome-padawan', (req, r) -> r.sendfile './public/welcomestudent.html'

  app.get     '/api/users/me', api_users.detail

  app.get     '/api/devs', api_devs.list
  app.get     '/api/devv/:id', api_devs.detail
  app.post    '/api/devs', api_devs.create
  app.put     '/api/devs/:id', api_devs.update
  app.delete  '/api/devs/:id', api_devs.delete

  app.get     '/api/skills', api_skills.list
  app.get     '/api/skills/:id', api_skills.detail
  app.post    '/api/skills', api_skills.create
  app.put     '/api/skills/:id', api_skills.update
  app.delete  '/api/skills/:id', api_skills.delete

  app.get     '/api/companys', api_companys.list
  app.get     '/api/companys/:id', api_companys.detail
  app.post    '/api/companys', api_companys.create
  app.put     '/api/companys/:id', api_companys.update
  app.delete  '/api/companys/:id', api_companys.delete

  app.get     '/api/requests', api_requests.list
  app.get     '/api/requests/:id', api_requests.detail
  app.post    '/api/requests', api_requests.create
  app.put     '/api/requests/:id', api_requests.update
  app.delete  '/api/requests/:id', api_requests.delete

  app.get     '/auth/github', auth.github.connect
  app.get     '/auth/github/callback', auth.github.connect, auth.github.done
  app.get     '/auth/google', auth.google.connect
  app.get     '/auth/google/callback', auth.google.connect, auth.google.done
  app.get     '/auth/twitter', auth.twitter.connect
  app.get     '/auth/twitter/callback', auth.twitter.connect, auth.twitter.done
  app.get     '/auth/linkedin', auth.linkedin.connect
  app.get     '/auth/linkedin/callback', auth.linkedin.connect, auth.linkedin.done

  app.get     '/logout', auth.logout