# See
# http://passportjs.org/
# http://passportjs.org/guide/oauth/
#
# Useful multi auth strategy gist
# https://gist.github.com/joshbirk/1732068

exports = {}
passport = require 'passport'
GoogleStrategy = require('passport-google').Strategy
GitHubStrategy = require('passport-github').Strategy

User = require './models/user'
User.remove({})

isDev = true

######## Shared

exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')


authnOrAuthz = (req, res, next, providerName, scope) ->
  opts = failureRedirect: '/failed-login', successRedirect: '/', scope: scope
  if req.isAuthenticated()
    console.log providerName, 'authorize'
    return passport.authorize(providerName+'-authz', opts)(req, res, next)
  else
    console.log providerName, 'authenticate'
    return passport.authenticate(providerName+'-authz', opts)(req, res, next)


insertOrUpdateUser = (req, done, providerName, profile) ->
  search = {}
  update = {}
  update[providerName+'Id'] = profile.id
  update[providerName] = profile

  if !req.user
    search[providerName+'Id'] = profile.id
  else
    search['_id'] = req.user._id

  User.findOneAndUpdate search, update, { upsert: true }, (err, user) ->
    #t = kind: 'oauth', token: token, attributes: { tokenSecret: tokenSecret }
    #user.tokens.push t
    done(err, user)


######## Session

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    console.log 'findById', user
    done err, user

######## Github

exports.github =

  dev_config:
    clientID:          '378dac2743563e96c747'
    clientSecret:      'f52d233259426f769850a13c95bfc3dbe7e3dbf2'
    callbackURL:       'http://localhost:3333/auth/github/callback'
    passReqToCallback: true

  connect: (req, res, next) -> authnOrAuthz req, res, next, 'github', ['user:email']

  done: (req, res) -> res.redirect '/'

  verifyCallback: (req, accessToken, refreshToken, profile, done) ->
    console.log 'githubVerifyCallback'
    delete profile._raw
    insertOrUpdateUser req, done, 'github', profile


config_github = exports.github.dev_config if isDev

passport.use 'github-authz', new GitHubStrategy config_github, exports.github.verifyCallback

######## Google

exports.google =

  dev_config:
    returnURL:         'http://localhost:3333/auth/google/return'
    realm:             'http://localhost:3333/'
    passReqToCallback: true

  connect: (req, res, next) ->
    authnOrAuthz req, res, next, 'google', [
     'https://www.googleapis.com/auth/userinfo.email',
     'https//www.googleapis.com/auth/plus.me' ]

  done: (req, res) -> res.redirect '/'

  verifyCallback: (req, identifier, profile, done) ->
    console.log 'googleVerifyCallback', identifier, profile
    profile.id = identifier
    insertOrUpdateUser req, done, 'google', profile

config_google = exports.google.dev_config if isDev

console.log 'config_google', config_google

passport.use 'google-authz', new GoogleStrategy config_google, exports.google.verifyCallback

######## Twitter

# exports.twitterSuccessCallback = (req, res) ->
#   user = req.user
#   account = req.account

#   # Associate the Twitter account with the logged-in user.
#   account.userId = user.id
#   account.save (err) ->
#     if err then return self.error(err)
#     self.redirect('/')


module.exports = exports