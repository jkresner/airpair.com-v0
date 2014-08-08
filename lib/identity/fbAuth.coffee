FirebaseTokenGenerator = require "firebase-token-generator"

module.exports = ->
  (req, res, next) ->
    tokenGenerator = new FirebaseTokenGenerator(config.airconf.chat.firebaseSecret)

    # are you using an airpair.com email address? then you're a chat admin
    isAdmin = _.contains(u.google._json.email, "@airpair.com")
    req.session.fba = tokenGenerator.createToken(user_id: u.googleId, admin: isAdmin)

    next()
