exports = {}
M       = require './Models'
BB      = require 'BB'
try
  AddJS = require '/scripts/providers/addjs/index'

class exports.AirpairRouter extends BB.BadassAppRouter

  preConstructorHook: ->
    if !addjs?
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
      created_at = new Date(parseInt(@app.session.id.toString().slice(0,8), 16)*1000)
      { email, name, picture, id, family_name, given_name } = google._json
      peopleProps = { email, name, picture, id, family_name, given_name, created_at }

    if !addjs? && AddJS?
      window.addjs = new AddJS
        providers: { ga: { logging: off }, mp: { logging: off, peopleProps: peopleProps } }

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->
    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'


  isAuthenticated: ->
    @app.session.authenticated()


  # routeMiddleware: (routeFn) ->
  #   $log 'window.location', window.location.pathname, routeFn.routeName
  #   addjs.trackPageView window.location.pathname, { route: routeFn.routeName }


module.exports = exports
