roles = require './roles'

module.exports = (options) ->

  if typeof options == 'string'
    options = redirectTo: options

  options = options || {}

  url = options.redirectTo || '/'

  (req, res, next) ->

    if ! roles.isAdmin req

      return res.redirect url

    next()