RemebermeStrategy = require('passport-remember-me').Strategy


setRemmeberMeCookie = (req, res, next) ->
  token = utils.generateToken(64)
  Token.save token, { userId: req.user.id }, (err) ->
    if err then return done(err)
    res.cookie('remember_me', token, { path: '/', httpOnly: true, maxAge: 2419200000 }) # 1 month
    next()


module.exports = (auth, passport) ->

  callback1 = (token, done) ->
      Token.consume token, (err, user) ->
        if err then return done(err)
        if !user then return done(null, false)
        done(null, user)

  callback2 = (user, done) ->
      token = utils.generateToken(64)
      Token.save token, { userId: user.id }, (err) ->
        if err then return done(err)
        done(null, token)

  passport.use 'remember-me', new RemebermeStrategy callback1, callback2

