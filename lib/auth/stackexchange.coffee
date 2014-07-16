StackExchangeStrategy = require('passport-stackexchange').Strategy

class StackExchange

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = _.clone config.stackexchange
    envConfig.callbackURL = "#{config.oauthHost}/auth/stackexchange/callback"
    envConfig.passReqToCallback = true
    @passport.use 'stack-authz', new StackExchangeStrategy envConfig, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, accessToken, refreshToken, profile, done) =>
    $log 'stackexchangeCallback', profile, done
    delete profile._raw # remove extra repetitive junk
    profile.id = profile.user_id
    profile.token = token: accessToken, attributes: { refreshToken: refreshToken }
    @auth.insertOrUpdateUser req, done, 'stack', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'stack', []

  # Completed action
  done: (req, res) =>
    $log 'stack.done'
    #res.send req.user
    res.redirect '/be-an-expert'

module.exports = (auth, passport) -> new StackExchange(auth, passport)
