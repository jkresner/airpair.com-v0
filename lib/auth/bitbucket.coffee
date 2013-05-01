BitBucketStrategy = require('passport-bitbucket').Strategy

config =
  dev:
    consumerKey: 'QNw3HsMSKzM6ptP4G4',
    consumerSecret: 'Cx5pvK2ZEjsymVxME42hSffkzkaQ9Buf',
    callbackURL: "http://localhost:3333/auth/bitbucket/callback"
    passReqToCallback: true

  staging:
    consumerKey: 'aLajWwZkcLY7jThvWZ',
    consumerSecret: 'gJtv3zmpzFJvh4V3kvzfegAxDKWcYw8h',
    callbackURL: "http://staging.airpair.com/auth/bitbucket/callback"
    passReqToCallback: true

  prod:
    consumerKey: 'WpdhX5mWW4wmLuDPwA',
    consumerSecret: 'Cx5pvK2ZEjsymVxME42hSffkzkaQ9Buf',
    callbackURL: "http://www.airpair.com/auth/bitbucket/callback"
    passReqToCallback: true


class BitBucket

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = @auth.getEnvConfig(config)
    passport.use 'bitbucket-authz', new BitBucketStrategy envConfig, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, token, tokenSecret, profile, done) =>
    # console.log 'bitbucketVerifyCallback', profile
    delete profile._raw
    profile.token = token: token, attributes: { tokenSecret: tokenSecret }
    profile.id = profile.username
    @auth.insertOrUpdateUser req, done, 'bitbucket', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'bitbucket', []

  # Completed action
  done: (req, res) =>
    #res.send req.user
    res.redirect '/be-an-expert'


module.exports = (auth, passport) -> new BitBucket(auth, passport)