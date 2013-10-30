GitHubStrategy = require('passport-github').Strategy

config =
  dev:
    clientID:          '378dac2743563e96c747'
    clientSecret:      'f52d233259426f769850a13c95bfc3dbe7e3dbf2'
    customHeaders:      {"User-Agent" : "airpair-com"}

  staging:
    clientID:           'e4917fcf822c02fd04f6'
    clientSecret:       '14292d0a3f665f73dde448fc90ff6c402ab6da9b'
    customHeaders:      {"User-Agent" : "airpair-com"}

  prod:
    clientID:          '5adb6a29c586908f8161'
    clientSecret:      'c4182b3402aa93dd6465e99ca90f2650a0596997'
    customHeaders:      {"User-Agent" : "airpair-com"}


class Github

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = @auth.getEnvConfig(config)
    envConfig.callbackURL = "#{cfg.oauthHost}/auth/github/callback"
    envConfig.passReqToCallback = true
    passport.use 'github-authz', new GitHubStrategy envConfig, @verifyCallback

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