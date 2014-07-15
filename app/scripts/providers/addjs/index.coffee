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
        gravatar: @peopleProps.picture
        name: @peopleProps.name
        last_name: @peopleProps.family_name
        first_name: @peopleProps.given_name
        created: @peopleProps.created_at
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
