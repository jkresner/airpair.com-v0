roles = require './roles'

module.exports = ->

  (req, res, next) ->

    if ! roles.isAdmin(req)

      return res.send(403, {})

    next()