BitBucketStrategy = require('passport-bitbucket').Strategy

dev_config =
  consumerKey: 'QNw3HsMSKzM6ptP4G4',
  consumerSecret: 'Cx5pvK2ZEjsymVxME42hSffkzkaQ9Buf',
  callbackURL: "http://localhost:3333/auth/bitbucket/callback"
  passReqToCallback: true

prod_config =
  consumerKey: 'WpdhX5mWW4wmLuDPwA',
  consumerSecret: 'Cx5pvK2ZEjsymVxME42hSffkzkaQ9Buf',
  callbackURL: "http://www.airpair.com/auth/bitbucket/callback"
  passReqToCallback: true


class BitBucket

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'bitbucket-authz', new BitBucketStrategy config, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, token, tokenSecret, profile, done) =>
    console.log 'bitbucketVerifyCallback', profile
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