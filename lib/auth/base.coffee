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
  User.findById id, (err, user) ->
    console.log '=================================================='
    email = if user? then user.google._json.email else "anonymous"
    console.log 'deserializeUser.id', id, email
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

  update['referrer'] = {}
  for cookieName in ['landingPage', 'utm_source', 'utm_medium', 'utm_term', 'utm_content', 'utm_campaign']
    if req.cookies[cookieName]
      update['referrer'][cookieName] = req.cookies[cookieName]

  saveUser = =>
    User.findOneAndUpdate search, update, { upsert: true }, (err, user) ->
      console.log 'findOneAndUpdate', err && err.stack, JSON.stringify(user)
      done(err, user)

  # We are only tracking sign ups from known flows (1:Request,2:BeExpert)
  mpId = req.session.mixpanelId if req.session
  $log 'mpIdExists', mpId?, mpId
  if mpId?
    User.findOne search, (err, user) ->
      if err then return done err
      $log 'userExists', user?, user
      if !user?
        mixpanel.alias mpId, update.google._json.email, =>
          $log 'alias callback', update.google._json.email, mpId
          mixpanel.track 'signUp', { distinct_id: mpId }, =>
            console.log 'signUp mixpanel.track callback'
      saveUser()
  else
    saveUser()




######## Load Providers

# rememberme = require('./rememberme')(exports, passport)
github = require('./github')(exports, passport)
google = require('./google')(exports, passport)
twitter = require('./twitter')(exports, passport)
linkedin = require('./linkedin')(exports, passport)
stackexchange = require('./stackexchange')(exports, passport)
bitbucket = require('./bitbucket')(exports, passport)

setReturnTo = (req, r, next) ->
  ref = req.query["return_to"]
  if ref?
    req.session.returnTo = ref
    $log 'req.session.returnTo', ref
  next()

setMixPanelId = (req, r, next) ->
  ref = req.query["mixpanelId"]
  if ref?
    req.session.mixpanelId = ref
    $log 'req.session.mixpanelId', ref
  next()

module.exports = (app) ->
  app.get     '/logout', logout
  app.get     '/failed-login', (req, r) -> r.send 'something went wrong with login ...'
  app.get     '/auth/google', setReturnTo, setMixPanelId, google.connect
  app.get     '/auth/google/callback', google.connect, google.done
  app.get     '/auth/github', github.connect
  app.get     '/auth/github/callback', github.connect, github.done
  app.get     '/auth/twitter', twitter.connect
  app.get     '/auth/twitter/callback', twitter.connect, twitter.done
  app.get     '/auth/linkedin', linkedin.connect
  app.get     '/auth/linkedin/callback', linkedin.connect, linkedin.done
  app.get     '/auth/stackexchange', stackexchange.connect
  app.get     '/auth/stackexchange/callback', stackexchange.connect, stackexchange.done
  app.get     '/auth/bitbucket', bitbucket.connect
  app.get     '/auth/bitbucket/callback', bitbucket.connect, bitbucket.done

