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
User.find({}).remove()

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  console.log '=================================================='
  console.log 'deserializeUser.id', id
  User.findById id, (err, user) ->
    done err, user

######## Shared

exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')


exports.authnOrAuthz = (req, res, next, providerName, scope) ->

  opts = failureRedirect: '/failed-login', scope: scope

  if req.isAuthenticated()
    console.log providerName, 'authorize'
    return passport.authorize(providerName+'-authz', opts)(req, res, next)
  else
    console.log providerName, 'authenticate'
    opts.successReturnToOrRedirect = req.header('Referer')
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

exports.github = require('./github')(exports, passport)
exports.google = require('./google')(exports, passport)
exports.twitter = require('./twitter')(exports, passport)
exports.linkedin = require('./linkedin')(exports, passport)


module.exports = exports