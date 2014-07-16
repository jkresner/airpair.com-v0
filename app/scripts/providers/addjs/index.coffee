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
      analytics.alias(@peopleProps.email, null, null, @trackSession)
    else
      console.log("Aliasing new user Failed")

  trackSession: (additionalProperties={}) =>
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

  trackPageView: (name, data) ->
    # segment.io automatically tracks page views
    # only use this method for client side page
    # views (a la angular)
    analytics.page(name, data)

  trackLink: (link, name, options) ->
    analytics.trackLink(link, name, options)

  bindTrackLinks: ->
    jQuery(".trackBookLogin").click (e) ->
      return_to = jQuery(this).attr("href")
      return_to = window.location.pathname + window.location.search  if return_to is "#"
      @trackLink "auth/google?return_to=" + return_to, @events.customerBookLogin.name, elementId: getElmId(this)
      true

    jQuery(".trackLogin,.trackCustomerLogin").click (e) ->
      @trackLink "auth/google?return_to=/find-an-expert", @events.customerLogin.name, elementId: getElmId(this)
      true

    jQuery(".trackExpertLogin").click (e) ->
      @trackLink "auth/google?return_to=/be-an-expert", @events.expertLogin.name, elementId: getElmId(this)
      true
