module.exports = (options) ->

  if typeof options == 'string'
    options = redirectTo: options

  options = options || {}

  url = options.redirectTo || '/'

  (req, res, next) ->

    # check for JK
    if req.user.googleId != '117132380360243205600'

      return res.redirect url

    next()