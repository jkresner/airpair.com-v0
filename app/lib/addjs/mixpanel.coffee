module.exports = class AddjsMixPanel

  constructor: (args) ->

    if args && args.logging then @logging = on

    if @logging is on
      console.log 'Addjs.MP.constructor', @, args

    if args.superProps then @superProps = args.superProps


  trackSession: ->
    if @logging is on
      console.log 'Addjs.MP.trackSession', @superProps
    if mixpanel?
      if @superProps? && @superProps.email?
        mixpanel.alias @superProps.email
        mixpanel.people.set_once
          $email: @superProps.email
          $gravatar: @superProps.picture

      # mixpanel.register @superProps



  trackEvent: (category, action, label, value) ->
    if @logging is on
      console.log 'Addjs.MP.Event', action, { category, label, value }

    if mixpanel?
      mixpanel.track( action, { category, label, value } )


  trackLink: (selector, category, action, label)->
    if @logging is on
      console.log 'Addjs.MP.trackLink', action, { category, label }

    if mixpanel?
      mixpanel.track_links( action, { category, label } )


  trackPageView: (url, data) ->
    if @logging is on
      console.log 'Addjs.MP.trackPageView', url, data
    if mixpanel?
      mixpanel.track_pageview url, data

  # trackSocial: (network, socialAction, opt_target, opt_pagePath) ->

  #   if @logging is on
  #     console.log 'Addjs.MixPanel.Social', network, socialAction, opt_target, opt_pagePath

  #   if mixpanel?
  #     ga 'send', 'social', network, socialAction, opt_target, opt_pagePath