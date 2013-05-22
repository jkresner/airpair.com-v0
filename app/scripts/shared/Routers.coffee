exports = {}
M = require './Models'
BB = require './../../lib/BB'


class exports.AirpairRouter extends BB.BadassAppRouter

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'


class exports.AirpairSessionRouter extends BB.SessionRouter

  model: M.User

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'

  isAuthenticated: ->
    @app.session.authenticated()


module.exports = exports