#  https://github.com/jaredhanson/connect-ensure-login/blob/master/lib/ensureLoggedIn.js

module.exports = ->

  (req, res, next) ->

    if !req.isAuthenticated || !req.isAuthenticated()

      return res.send(403, {})

    # check for JK
    if req.user.googleId != '117132380360243205600'

      return res.send(403, {})

    next()