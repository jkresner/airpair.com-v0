GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

class Google

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = _.clone config.google.passport
    envConfig.callbackURL = "#{config.oauthHost}/auth/google/callback"
    envConfig.passReqToCallback = true
    passport.use 'google-authz', new GoogleStrategy envConfig, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, accessToken, refreshToken, profile, done) =>
    #console.log 'googleVerifyCallback', profile, done
    delete profile._raw # remove extra repetitive junk
    profile.token = token: accessToken, attributes: { refreshToken: refreshToken }
    @auth.insertOrUpdateUser req, done, 'google', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'google', [
     'https://www.googleapis.com/auth/plus.me',
     'https://www.googleapis.com/auth/userinfo.email',
     'https://www.googleapis.com/auth/userinfo.profile' ]#,
     # 'https://www.googleapis.com/auth/calendar' ]

  # Completed action
  done: (req, res) =>
    returnUrl = '/'
    returnUrl = req.session.returnTo if req.session.returnTo?
    res.redirect returnUrl

module.exports = (auth, passport) -> new Google(auth, passport)
