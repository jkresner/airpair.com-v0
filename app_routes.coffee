auth = require './auth'
api_users = require './api/users'
api_skills = require './api/skills'
api_devs = require './api/devs'
api_companys = require './api/companys'
api_requests = require './api/requests'

passport = require 'passport'

# ensureUnauthenticated = (req, res, next) ->
  # if req.isAuthenticated()
    # display an "already logged in" message
    # return res.redirect('/')
  # next()

module.exports = (app) ->

  app.get     '/', (req, res) -> res.sendfile './public/index.html'
  app.get     '/about', (req, res) -> res.sendfile './public/index.html'
  app.get     '/adminn', (req, res) -> res.sendfile './public/admin.html'
  app.get     '/review', (req, res) -> res.sendfile './public/review.html'
  app.get     '/be-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
  app.get     '/become-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
  app.get     '/find-an-expert', (req, res) -> res.sendfile './public/findexpert.html'
  app.get     '/traction', (req, res) -> res.sendfile './public/traction.html'

  app.get     '/welcome-expert', (req, res) -> res.sendfile './public/welcomeexpert.html'
  app.get     '/welcome-student', (req, res) -> res.sendfile './public/welcomestudent.html'

  app.get     '/api/users/me', api_users.detail

  app.get     '/api/devs', api_devs.list
  app.get     '/api/devv/:id', api_devs.detail
  app.post    '/api/devs', api_devs.post
  app.put     '/api/devs/:id', api_devs.update
  app.delete  '/api/devs/:id', api_devs.delete

  app.get     '/api/skills', api_skills.list
  app.get     '/api/skills/:id', api_skills.detail
  app.post    '/api/skills', api_skills.post
  app.put     '/api/skills/:id', api_skills.update
  app.put     '/api/skills/:id', api_skills.delete

  app.get     '/api/companys', api_companys.list
  app.get     '/api/companys/:id', api_companys.detail
  app.put     '/api/companys/:id', api_companys.update
  app.delete  '/api/companys/:id', api_companys.delete
  app.post    '/api/companys', api_companys.post

  app.get     '/api/requests', api_requests.list
  app.get     '/api/requests/:id', api_requests.detail
  app.put     '/api/requests/:id', api_requests.update
  app.delete  '/api/requests/:id', api_requests.delete
  app.post    '/api/requests', api_requests.post

  app.get     '/auth/github', auth.github.connect
  app.get     '/auth/github/callback', auth.github.connect, auth.github.done
  app.get     '/auth/google', auth.google.connect
  app.get     '/auth/google/callback', auth.google.connect, auth.google.done
  app.get     '/auth/twitter', auth.twitter.connect
  app.get     '/auth/twitter/callback', auth.twitter.connect, auth.twitter.done
  app.get     '/auth/linkedin', auth.linkedin.connect
  app.get     '/auth/linkedin/callback', auth.linkedin.connect, auth.linkedin.done

  # app.get     '/facebook-login', authnOrAuthzFacebook


  app.get     '/logout', auth.logout