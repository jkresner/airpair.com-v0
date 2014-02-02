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


  trackLanding: (data) ->
    urlWithoutQuery = window.location.pathname
    for k, p of @providers
      p.trackLanding.call(p, urlWithoutQuery, data)
      # mixpanel.register_once({ 'landing page': window.location.href });


  trackClick: (e, destUrl, evnt, elmId) =>
    if evnt?
      data = { page: window.location.pathname, section: elmId }
      @trackEvent evnt.category, evnt.name, evnt.uri, data

    if mixpanel?
      if e? then e.preventDefault()
      redirect = => window.location = "https://www.airpair.com/#{destUrl}&mixpanelId=#{mixpanel.get_distinct_id()}"
      setTimeout redirect 300
