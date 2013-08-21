exports = {}
M = require './Models'
BB = require './../../lib/BB'
AddJS = require '/lib/addjs/index'

class exports.AirpairRouter extends BB.BadassAppRouter

  preConstructorHook: ->
    window.addjs = new AddJS providers: { ga: { logging: on } }

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'



class exports.AirpairSessionRouter extends BB.SessionRouter

  model: M.User


  preConstructorHook: ->
    window.addjs = new AddJS providers: { ga: { logging: on } }

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'

  isAuthenticated: ->
    @app.session.authenticated()


module.exports = exports