TwitterStrategy = require('passport-twitter').Strategy

config =
  dev:
    consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ',
    consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM',
    callbackURL: "http://localhost:3333/auth/twitter/callback"
    passReqToCallback: true

  staging:
    consumerKey: 'hzcDmWTPJZFooDh6r0v9A',
    consumerSecret: 'NwA4bJc6RFAGeSbpYwuEX0CdiTuoDj3qzyXj9uCQNs',
    callbackURL: "http://staging.airpair.com/auth/twitter/callback"
    passReqToCallback: true

  prod:
    consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ',
    consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM',
    callbackURL: "http://www.airpair.com/auth/twitter/callback"
    passReqToCallback: true


class Twitter

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = @auth.getEnvConfig(config)
    passport.use 'twitter-authz', new TwitterStrategy envConfig, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, token, tokenSecret, profile, done) =>
    #console.log 'twitterVerifyCallback'
    delete profile._raw
    profile.token = token: token, attributes: { tokenSecret: tokenSecret }
    @auth.insertOrUpdateUser req, done, 'twitter', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'twitter', []

  # Completed action
  done: (req, res) =>
    #res.send req.user
    res.redirect '/be-an-expert'

module.exports = (auth, passport) -> new Twitter(auth, passport)