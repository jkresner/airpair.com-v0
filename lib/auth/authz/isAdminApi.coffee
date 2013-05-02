#  https://github.com/jaredhanson/connect-ensure-login/blob/master/lib/ensureLoggedIn.js

module.exports = ->

  (req, res, next) ->

    # check for JK / MA
    gid = req.user.googleId
    isAdmin = gid == '117132380360243205600' || gid == '105699130570311275819'

    if ! isAdmin

      return res.send(403, {})

    next()