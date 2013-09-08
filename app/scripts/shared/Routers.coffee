exports = {}
M = require './Models'
BB = require './../../lib/BB'
AddJS = require '/lib/addjs/index'

class exports.AirpairRouter extends BB.BadassAppRouter

  preConstructorHook: ->
    window.addjs = new AddJS providers: { ga: { logging: off }, mp: { logging: off } }

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'



class exports.AirpairSessionRouter extends BB.SessionRouter

  model: M.User


  preConstructorHook: ->
    # $log 'preConstructorHook', @routeMiddleware

    { google } = @app.session.attributes
    superProps = {}
    if google?
      { email, name, picture, id } = google._json
      superProps = { email, name, picture, id }

    window.addjs = new AddJS
      providers: { ga: { logging: off }, mp: { logging: on, superProps: superProps } }

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'

    addjs.providers.mp.trackSession()


  isAuthenticated: ->
    @app.session.authenticated()


  # routeMiddleware: (routeFn) ->
  #   $log 'window.location', window.location.pathname, routeFn.routeName
  #   addjs.trackPageView window.location.pathname, { route: routeFn.routeName }


module.exports = exports