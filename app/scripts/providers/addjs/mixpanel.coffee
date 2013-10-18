module.exports = class AddjsMixPanel

  constructor: (args) ->

    if args && args.logging then @logging = on

    if @logging is on
      console.log 'Addjs.MP.constructor', @debug(), args

    if args.superProps then @superProps = args.superProps


  trackSession: ->
    if @logging is on
      console.log 'Addjs.MP.trackSession', @debug(), @superProps
    if mixpanel?
      if @superProps? && @superProps.email?
        mixpanel.alias @superProps.email
        mixpanel.people.set_once
          $email: @superProps.email
          $gravatar: @superProps.picture
          LastName: @superProps.family_name
          FirstName: @superProps.given_name


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