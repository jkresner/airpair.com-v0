GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

dev_config =
  clientID:           '739031114792.apps.googleusercontent.com'
  clientSecret:       '8_1NuinvGy6ybpu0m2srvYjm'
  callbackURL:        "http://localhost:3333/auth/google/callback"
  passReqToCallback:  true

prod_config =
  clientID:           '739031114792.apps.googleusercontent.com'
  clientSecret:       '8_1NuinvGy6ybpu0m2srvYjm'
  callbackURL:        "http://#{process.env.OAUTH_Host}/auth/google/callback"
  passReqToCallback:  true


class Google

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'google-authz', new GoogleStrategy config, @verifyCallback

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
     'https://www.googleapis.com/auth/userinfo.profile',
     'https://www.googleapis.com/auth/calendar' ]

  # Completed action
  done: (req, res) => res.send req.user


module.exports = (auth, passport) -> new Google(auth, passport)