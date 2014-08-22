BitBucketStrategy = require('passport-bitbucket').Strategy

class BitBucket

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = _.clone config.bitbucket
    envConfig.callbackURL = "#{config.oauthHost}/auth/bitbucket/callback"
    envConfig.passReqToCallback = true
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
    res.redirect '/settings/expert'


module.exports = (auth, passport) -> new BitBucket(auth, passport)
