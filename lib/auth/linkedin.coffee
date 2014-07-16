LinkedInStrategy = require('passport-linkedin').Strategy

class LinkedIn

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = _.clone config.linkedin
    envConfig.callbackURL = "#{config.oauthHost}/auth/linkedin/callback"
    envConfig.passReqToCallback = true
    passport.use 'linkedin-authz', new LinkedInStrategy envConfig, @verifyCallback

  # Process the response from the external provider
  verifyCallback: (req, token, tokenSecret, profile, done) =>
    #console.log 'linkedInVerifyCallback', profile
    delete profile._raw
    profile.token = token: token, attributes: { tokenSecret: tokenSecret }
    @auth.insertOrUpdateUser req, done, 'linkedin', profile

  # Make the call to the external provider
  connect: (req, res, next) =>
    @auth.authnOrAuthz req, res, next, 'linkedin', ['r_fullprofile','r_network','rw_nus']

  # Completed action
  done: (req, res) =>
    #res.send req.user
    res.redirect '/be-an-expert'


module.exports = (auth, passport) -> new LinkedIn(auth, passport)
