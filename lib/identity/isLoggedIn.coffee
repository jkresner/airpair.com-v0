#  https://github.com/jaredhanson/connect-ensure-login/blob/master/lib/ensureLoggedIn.js

module.exports = (options) ->
  if typeof options == 'string'
    options = redirectTo: options

  options = options || {}

  url = options.redirectTo || '/login'
  setReturnTo = if options.setReturnTo is undefined then true else options.setReturnTo

  (req, res, next) ->
    console.log req.method, req.path

    if !req.isAuthenticated || !req.isAuthenticated()

      if setReturnTo && req.session
        req.session.returnTo = req.url

      if options.isApi
        return res.send 403, {}
      else
        if req.method == "HEAD"
          return res.end("")
        return res.redirect url

    next()
