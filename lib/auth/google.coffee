GoogleStrategy = require('passport-google').Strategy

dev_config =
  returnURL:         'http://localhost:3333/auth/google/callback'
  realm:             'http://localhost:3333/'
  passReqToCallback: true

prod_config =
  returnURL:         'http://www.airpair.com/auth/google/callback'
  realm:             'http://www.airpair.com/'
  passReqToCallback: true


class Google

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'google-authz', new GoogleStrategy config, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, identifier, profile, done) =>
    #console.log 'googleVerifyCallback', identifier, profile, done
    profile.id = identifier
    @auth.insertOrUpdateUser req, done, 'google', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'google', [
     'https://www.googleapis.com/auth/userinfo.email',
     'https://www.googleapis.com/auth/plus.me' ]

  # Completed action
  done: (req, res) =>
    #console.log 'google.done'
    res.send req.user


module.exports = (auth, passport) -> new Google(auth, passport)