module.exports = class Addjs

  Timer: require './timer'
  events: require './events'

  constructor: (segmentioKey, config={}) ->
    require("../segmentio")(segmentioKey)
    if @logging is on
      console.log 'Addjs.constructor'
      unless analytics?
        console.log 'Addjs.constructor', 'WARNING segment.io is not loaded'
    @peopleProps = config.peopleProps

  alias: ->
    if @peopleProps? && @peopleProps.email?
      console.log 'Addjs alias', @peopleProps.email
      analytics.alias(@peopleProps.email, null, null, @identify)
    else
      console.log 'Aliasing new user Failed'

  identify: (additionalProperties={}) =>
    if @peopleProps? && @peopleProps.email?
      properties =
        avatar: @peopleProps.picture
        email: @peopleProps.email
        name: @peopleProps.name
        lastName: @peopleProps.family_name
        firstName: @peopleProps.given_name
        createdAt: @peopleProps.created_at
      properties[key] = val for key, val of additionalProperties
      analytics.identify @peopleProps.email, properties
    else
      analytics.identify(additionalProperties)

  trackEvent: (category, action, label, value, bounce) ->
    analytics.track action,
      category: category
      label: label
      value: value
      bounce: bounce

  trackCustomEvent: (action, props) ->
    analytics.track action, props

  trackPageView: (name, data) ->
    # segment.io automatically tracks page views
    # only use this method for client side page
    # views (a la angular)
    analytics.page(name, data)

  trackLink: (link, name, options) ->
    analytics.trackLink(link, name, options)

  ###
  TODO: The following two functions do not belong in this file!
  ###
  bindTrackLinks: ->
    parent = @
    jQuery(".trackBookLogin").click (e) ->
      return_to = jQuery(this).attr("href")
      return_to = window.location.pathname + window.location.search  if return_to is "#"
      event = parent.events.customerBookLogin
      parent.trackEvent event.category, event.name, "#{window.location.pathname}:#{@id}"
      parent.redirectToLogin(e, "auth/google?return_to=" + return_to)

    jQuery(".trackLogin,.trackCustomerLogin").click (e) ->
      event = parent.events.customerLogin
      parent.trackEvent event.category, event.name, "#{window.location.pathname}:#{@id}"
      parent.redirectToLogin(e, "auth/google?return_to=/find-an-expert")

    jQuery(".trackExpertLogin").click (e) ->
      event = parent.events.expertLogin
      parent.trackEvent event.category, event.name, "#{window.location.pathname}:#{@id}"
      parent.redirectToLogin(e, "auth/google?return_to=/be-an-expert")

  redirectToLogin: (e, destinationUrl) ->
    if e? then e.preventDefault()
    redirectLocation = "#{window.location.origin}/#{destinationUrl}"
    redirect = =>
      window.location = redirectLocation
    setTimeout(redirect,300)
