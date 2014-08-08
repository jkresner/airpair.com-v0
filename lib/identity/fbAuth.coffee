FirebaseTokenGenerator = require "firebase-token-generator"

module.exports = ->
  (req, res, next) ->
    req.firebase =
      path: config.airconf.chat.firebasePath

    if req.user?
      tokenGenerator = new FirebaseTokenGenerator(config.airconf.chat.firebaseSecret)

      # are you using an airpair.com email address? then you're a chat admin
      req.firebase.isAdmin = _.contains(req.user.google._json.email, "@airpair.com")
      req.firebase.token = tokenGenerator.createToken(user_id: req.user.googleId, admin: req.firebase.isAdmin)

    next()
