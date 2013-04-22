GitHubStrategy = require('passport-github').Strategy

dev_config =
  clientID:          '378dac2743563e96c747'
  clientSecret:      'f52d233259426f769850a13c95bfc3dbe7e3dbf2'
  callbackURL:       'http://localhost:3333/auth/github/callback'
  passReqToCallback: true

prod_config =
  clientID:          '5adb6a29c586908f8161'
  clientSecret:      'c4182b3402aa93dd6465e99ca90f2650a0596997'
  callbackURL:       'http://#{process.env.OAUTH_Host}/auth/github/callback'
  passReqToCallback: true


class Github

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'github-authz', new GitHubStrategy config, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, accessToken, refreshToken, profile, done) =>
    delete profile._raw # remove extra repetitive junk
    profile.token = token: accessToken, attributes: { refreshToken: refreshToken }
    @auth.insertOrUpdateUser req, done, 'github', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'github', ['user:email']

  # Completed action
  done: (req, res) =>
    # $log 'github.done', req.callbackURL
    # res.send req.user
    res.redirect '/be-an-expert'


module.exports = (auth, passport) -> new Github(auth, passport)