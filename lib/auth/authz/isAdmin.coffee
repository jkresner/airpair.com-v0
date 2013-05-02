module.exports = (options) ->

  if typeof options == 'string'
    options = redirectTo: options

  options = options || {}

  url = options.redirectTo || '/'

  (req, res, next) ->

    # check for JK / MA
    gid = req.user.googleId
    isAdmin = gid == '117132380360243205600' || gid == '105699130570311275819'

    if ! isAdmin

      return res.redirect url

    next()