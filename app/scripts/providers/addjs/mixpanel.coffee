module.exports = class AddjsMixPanel

  constructor: (args) ->

    if args && args.logging then @logging = on

    if @logging is on
      console.log 'Addjs.MP.constructor', @debug(), args

    if args.peopleProps then @peopleProps = args.peopleProps


  trackSession: ->
    if @logging is on
      console.log 'Addjs.MP.trackSession', @debug(), @peopleProps
    if mixpanel?
      if @peopleProps? && @peopleProps.email?
        mixpanel.identify @peopleProps.email
        mixpanel.people.set_once
          $email: @peopleProps.email
          $gravatar: @peopleProps.picture
          $name: @peopleProps.name          
          $last_name: @peopleProps.family_name
          $first_name: @peopleProps.given_name
          $created: @peopleProps.created_at

  setPeopleProps: (props) ->
    if mixpanel?
      mixpanel.people.set_once props

  incrementPeopleProp: (propName) ->
    if mixpanel?
      mixpanel.people.increment propName

  trackEvent: (category, action, label, value) ->
    if @logging is on
      console.log 'Addjs.MP.Event', @debug(), action, { category, label, value }

    if mixpanel?
      mixpanel.track( action, { category, label, value } )


  trackLink: (selector, category, action, label)->
    if @logging is on
      console.log 'Addjs.MP.trackLink', @debug(), action, { category, label }

    if mixpanel?
      mixpanel.track_links( action, { category, label } )


  trackPageView: (url, data) ->
    if @logging is on
      console.log 'Addjs.MP.trackPageView', @debug(), url, data
    if mixpanel?
      mixpanel.track_pageview url, data


  trackLanding: (url, data) ->
    if @logging is on
      console.log 'Addjs.MP.trackLanding', @debug(), url, data
    if mixpanel?
      data.url = url
      mixpanel.track( 'landingPage', data )


  debug: ->
    "init[#{mixpanel?}]"

  # trackSocial: (network, socialAction, opt_target, opt_pagePath) ->

  #   if @logging is on
  #     console.log 'Addjs.MixPanel.Social', network, socialAction, opt_target, opt_pagePath

  #   if mixpanel?
  #     ga 'send', 'social', network, socialAction, opt_target, opt_pagePath