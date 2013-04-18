StackExchangeStrategy = require('passport-stackexchange').Strategy

config =
  clientID:          '1432'
  clientSecret:      'oA5O0hVgWg3muObSVC8mSQ(('
  key:               'h0fVRSYpv0*MAKD7HXj5bw(('
  callbackURL:       'http://localhost:3333/auth/stackexchange/callback'
  passReqToCallback: true


class StackExchange

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    @passport.use 'stackexchange', new StackExchangeStrategy config, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, accessToken, refreshToken, profile, done) =>
    #console.log 'stackexchangeCallback', profile, done
    delete profile._raw # remove extra repetitive junk
    profile.token = token: accessToken, attributes: { refreshToken: refreshToken }
    @auth.insertOrUpdateUser req, done, 'stackexchange', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'stackexchange', []

  # Completed action
  done: (req, res) => res.send req.user


module.exports = (auth, passport) -> new StackExchange(auth, passport)