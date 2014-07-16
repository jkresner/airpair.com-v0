exports = {}
Models = require './Models'
BB = require 'BB'
AddJS = require '/scripts/providers/addjs/index'

getElmId = (elm) ->
  elmId = jQuery(elm).attr("id")
  elmId = jQuery(elm).parent().attr("id")  if _.isEmpty(elmId)
  elmId

class exports.AirpairRouter extends BB.BadassAppRouter

  preConstructorHook: (pageData) ->
    unless addjs?
      window.addjs = new AddJS(pageData.segmentioKey)
      addjs.trackSession()
      addjs.bindTrackLinks()

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in uservoice & other 3rd party things
    require '/scripts/providers/all'

class exports.AirpairSessionRouter extends BB.SessionRouter

  model: Models.User

  preConstructorHook: (pageData) ->
    # $log 'preConstructorHook', @routeMiddleware

    { google } = @app.session.attributes
    superProps = {}
    if google?
      created_at = new Date(parseInt(@app.session.id.toString().slice(0,8), 16)*1000)
      { email, name, picture, id, family_name, given_name } = google._json
      peopleProps = { email, name, picture, id, family_name, given_name, created_at }

    unless addjs?
      window.addjs = new AddJS pageData.segmentioKey, { peopleProps: peopleProps }

      if window.location.search.match(/newUser/)?
        addjs.alias()
        event = addjs.events.signUp
        addjs.trackEvent event.category, event.name, window.location.pathname, 0
      else
        addjs.trackSession()
        addjs.bindTrackLinks()

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->
    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'

  isAuthenticated: ->
    @app.session.authenticated()

module.exports = exports
