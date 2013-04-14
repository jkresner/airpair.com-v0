TwitterStrategy = require('passport-twitter').Strategy

dev_config =
  consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ',
  consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM',
  callbackURL: "http://localhost:3333/auth/twitter/callback"
  passReqToCallback: true

prod_config =
  consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ',
  consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM',
  callbackURL: "http://www.airpair.com/auth/twitter/callback"
  passReqToCallback: true


class Twitter

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'twitter-authz', new TwitterStrategy config, @verifyCallback

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
  done: (req, res) => res.send req.user


module.exports = (auth, passport) -> new Twitter(auth, passport)