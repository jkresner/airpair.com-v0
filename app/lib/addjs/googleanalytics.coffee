module.exports = class AddjsGoogleAnalytics

  constructor: (args) ->

    if args && args.logging then @logging = on

    if @logging is on
      console.log 'AddjsGoogleAnalytics.constructor', @, args


  trackEvent: (category, action, label, value, bounce) ->
    if @logging is on
      console.log 'Addjs.GA.Event', category, action, label, value, bounce

    if ga?
      ga 'send', 'event', category, action, label, value, bounce


  trackSocial: (network, socialAction, opt_target, opt_pagePath) ->

    if @logging is on
      console.log 'Addjs.GA.Social', network, socialAction, opt_target, opt_pagePath

    if ga?
      ga 'send', 'social', network, socialAction, opt_target, opt_pagePath