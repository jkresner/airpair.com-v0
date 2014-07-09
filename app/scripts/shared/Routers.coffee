exports = {}
Models = require './Models'
BB = require 'BB'
try
  AddJS = require '/scripts/providers/addjs/index'

getElmId = (elm) ->
  elmId = jQuery(elm).attr("id")
  elmId = jQuery(elm).parent().attr("id")  if _.isEmpty(elmId)
  elmId

class exports.AirpairRouter extends BB.BadassAppRouter

  preConstructorHook: ->
    if !addjs?
      window.addjs = new AddJS()
      addjs.trackSession()
      jQuery(".trackBookLogin").click (e) ->
        return_to = jQuery(this).attr("href")
        return_to = window.location.pathname + window.location.search  if return_to is "#"
        addjs.trackLink "auth/google?return_to=" + return_to, addjs.events.customerBookLogin.name, elementId: getElmId(this)

      jQuery(".trackLogin,.trackCustomerLogin").click (e) ->
        addjs.trackLink "auth/google?return_to=/find-an-expert", addjs.events.customerLogin.name, elementId: getElmId(this)
        return

      jQuery(".trackExpertLogin").click (e) ->
        addjs.trackLink "auth/google?return_to=/be-an-expert", addjs.events.expertLogin.name, elementId: getElmId(this)
        return

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->

    # bring in uservoice & other 3rd party things
    require '/scripts/providers/all'

class exports.AirpairSessionRouter extends BB.SessionRouter

  model: Models.User

  preConstructorHook: ->
    # $log 'preConstructorHook', @routeMiddleware

    { google } = @app.session.attributes
    superProps = {}
    if google?
      created_at = new Date(parseInt(@app.session.id.toString().slice(0,8), 16)*1000)
      { email, name, picture, id, family_name, given_name } = google._json
      peopleProps = { email, name, picture, id, family_name, given_name, created_at }

    if !addjs? && AddJS?
      window.addjs = new AddJS { peopleProps: peopleProps }
      addjs.trackSession()

      if window.location.search.match(/newUser/)?
        addjs.alias()

      jQuery(".trackBookLogin").click (e) ->
        return_to = jQuery(this).attr("href")
        return_to = window.location.pathname + window.location.search  if return_to is "#"
        addjs.trackLink "auth/google?return_to=" + return_to, addjs.events.customerBookLogin.name, elementId: getElmId(this)

      jQuery(".trackLogin,.trackCustomerLogin").click (e) ->
        addjs.trackLink "auth/google?return_to=/find-an-expert", addjs.events.customerLogin.name, elementId: getElmId(this)
        return

      jQuery(".trackExpertLogin").click (e) ->
        addjs.trackLink "auth/google?return_to=/be-an-expert", addjs.events.expertLogin.name, elementId: getElmId(this)
        return

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->
    # bring in Google analytics, uservoice & other 3rd party things
    require '/scripts/providers/all'

  isAuthenticated: ->
    @app.session.authenticated()

module.exports = exports
