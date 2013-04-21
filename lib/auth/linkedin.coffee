LinkedInStrategy = require('passport-linkedin').Strategy

dev_config =
  consumerKey: 'sy5n2q8o2i49',  #linkedIN api key
  consumerSecret: 'lcKjdbFSNG3HfZsd', #linkedIn secret key
  callbackURL: "http://localhost:3333/auth/linkedin/callback"
  passReqToCallback: true

prod_config =
  consumerKey: 'sy5n2q8o2i49',  #linkedIN api key
  consumerSecret: 'lcKjdbFSNG3HfZsd', #linkedIn secret key
  callbackURL: "http://www.airpair.com/auth/linkedin/callback"
  passReqToCallback: true


class LinkedIn

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    config = if isProd then prod_config else dev_config
    passport.use 'linkedin-authz', new LinkedInStrategy config, @verifyCallback

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