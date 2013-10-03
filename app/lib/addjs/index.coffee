Events = require './events'
AddjsGoogleAnalytics = require './googleanalytics'
AddjsMixPanel = require './mixpanel'
# AddjsOptimizely = require './addjs/optimizely'

module.exports = class Addjs

  Timer: require './timer'
  events: require './events'

  providers: {}

  constructor: (config) ->

    if @logging is on
      console.log 'Addjs.constructor', config, @providers

    if config.providers.ga
      @providers.ga = new AddjsGoogleAnalytics config.providers.ga

    if config.providers.mp
      @providers.mp = new AddjsMixPanel config.providers.mp

    # if config.providers.optimizely
    #   providers.op = new AddjsOptimizely config.providers.optimizely


  trackEvent: (category, action, label, value, bounce) ->
    for k, p of @providers
      p.trackEvent.apply(p, arguments)


  trackSocial: (network, socialAction, opt_target, opt_pagePath) ->
    for k, p of @providers
      p.trackSocial.apply(p, arguments)


  trackPageView: (url, data) ->
    for k, p of @providers
      p.trackPageView.apply(p, arguments)


  trackLanding: (url, data) ->
    for k, p of @providers
      p.trackLanding.apply(p, arguments)



      mixpanel.register_once({ 'landing page': window.location.href });