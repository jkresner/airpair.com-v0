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


######## Session

passport.serializeUser (user, done) ->
  done null, user.id


passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    console.log 'findById', user
    done err, user

######## Github

dev_auth_config_github =
  clientID:     '378dac2743563e96c747'
  clientSecret: 'f52d233259426f769850a13c95bfc3dbe7e3dbf2'
  callbackURL:  'http://localhost:3333/auth/github/callback'


# todo add prod config
github_auth_config = dev_auth_config_github if true

github_auth_callback = (accessToken, refreshToken, profile, done) ->

  console.log 'github auth success!!!'
  User.findOneAndUpdate { githubId: profile.id}, { github: profile }, { upsert: true }, (err, user) ->
    # console.log 'user created', user
    done(err, user)


githubStrategy = new GitHubStrategy github_auth_config, github_auth_callback


passport.use 'github', githubStrategy


######## Google


######## Twitter

exports.twitterSuccessCallback = (req, res) ->
  user = req.user
  account = req.account

  # Associate the Twitter account with the logged-in user.
  account.userId = user.id
  account.save (err) ->
    if err then return self.error(err)
    self.redirect('/')


exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')


module.exports = exports