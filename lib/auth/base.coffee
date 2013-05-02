# See
# http://passportjs.org/
# http://passportjs.org/guide/oauth/
#
# Useful multi auth strategy gist
# https://gist.github.com/joshbirk/1732068

exports = {}
und = require 'underscore'
passport = require 'passport'

######## Session

User = require './../models/user'

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  console.log '=================================================='
  console.log 'deserializeUser.id', id
  User.findById id, (err, user) ->
    done err, user

######## Shared


logout = (req, res) ->
  req.logout()
  res.redirect('/')


exports.getEnvConfig = (config) ->
  env = process.env.OAUTH_Env
  if env? && env is 'staging' then return config.staging
  if env? && env is 'prod' then return config.prod
  config.dev


exports.authnOrAuthz = (req, res, next, providerName, scope) ->

  opts = failureRedirect: '/failed-login', scope: scope

  if req.isAuthenticated()
    console.log providerName, 'authorize'
    return passport.authorize(providerName+'-authz', opts)(req, res, next)
  else
    console.log providerName, 'authenticate'
    opts.successReturnToOrRedirect = '/'
    return passport.authenticate(providerName+'-authz', opts)(req, res, next)


exports.insertOrUpdateUser = (req, done, providerName, profile) ->
  search = {}
  update = {}
  update[providerName+'Id'] = profile.id
  update[providerName] = profile

  if !req.user
    search[providerName+'Id'] = profile.id
  else
    search['_id'] = req.user._id

  User.findOneAndUpdate search, update, { upsert: true }, (err, user) ->
    # console.log '=================================================='
    # console.log 'findOneAndUpdate', err, done, user
    done(err, user)


######## Load Providers

github = require('./github')(exports, passport)
google = require('./google')(exports, passport)
twitter = require('./twitter')(exports, passport)
linkedin = require('./linkedin')(exports, passport)
stackexchange = require('./stackexchange')(exports, passport)
bitbucket = require('./bitbucket')(exports, passport)

setReturnTo = (req, r, next) ->
  ref = req.query["return_to"]
  if ref? then req.session.returnTo = ref
  next()

module.exports = (app) ->
  app.get     '/logout', logout
  app.get     '/failed-login', (req, r) -> r.send 'something went wrong with login ...'
  app.get     '/auth/github', github.connect
  app.get     '/auth/github/callback', github.connect, github.done
  app.get     '/auth/google', setReturnTo, google.connect
  app.get     '/auth/google/callback', google.connect, google.done
  app.get     '/auth/twitter', twitter.connect
  app.get     '/auth/twitter/callback', twitter.connect, twitter.done
  app.get     '/auth/linkedin', linkedin.connect
  app.get     '/auth/linkedin/callback', linkedin.connect, linkedin.done
  app.get     '/auth/stackexchange', stackexchange.connect
  app.get     '/auth/stackexchange/callback', stackexchange.connect, stackexchange.done
  app.get     '/auth/bitbucket', bitbucket.connect
  app.get     '/auth/bitbucket/callback', bitbucket.connect, bitbucket.done

