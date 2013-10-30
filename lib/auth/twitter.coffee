TwitterStrategy = require('passport-twitter').Strategy

config =
  dev:
    consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ'
    consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM'

  staging:
    consumerKey: 'hzcDmWTPJZFooDh6r0v9A'
    consumerSecret: 'NwA4bJc6RFAGeSbpYwuEX0CdiTuoDj3qzyXj9uCQNs'

  prod:
    consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ'
    consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM'

class Twitter

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = @auth.getEnvConfig(config)
    envConfig.callbackURL = "#{cfg.oauthHost}/auth/twitter/callback"
    envConfig.passReqToCallback = true    
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