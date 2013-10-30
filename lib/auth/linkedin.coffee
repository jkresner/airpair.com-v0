LinkedInStrategy = require('passport-linkedin').Strategy

config =
  dev:
    consumerKey: 'sy5n2q8o2i49'  #linkedIN api key
    consumerSecret: 'lcKjdbFSNG3HfZsd' #linkedIn secret key

  staging:
    consumerKey: 'rgd74pv5o45c'  #linkedIN api key
    consumerSecret: 'd6fTF24fLvDe51zf' #linkedIn secret key

  prod:
    consumerKey: 'sy5n2q8o2i49',  #linkedIN api key
    consumerSecret: 'lcKjdbFSNG3HfZsd' #linkedIn secret key



class LinkedIn

  constructor: (auth, passport) ->
    @auth = auth
    @passport = passport
    envConfig = @auth.getEnvConfig(config)    
    envConfig.callbackURL = "#{cfg.oauthHost}/auth/linkedin/callback"
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