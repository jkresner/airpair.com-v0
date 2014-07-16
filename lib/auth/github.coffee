GitHubStrategy = require('passport-github').Strategy

class Github

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = _.clone config.github
    envConfig.callbackURL = "#{config.oauthHost}/auth/github/callback"
    envConfig.passReqToCallback = true
    envConfig.customHeaders = {"User-Agent" : "airpair-com"}
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
