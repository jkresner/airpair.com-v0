"""
  BadassRouter takes the philosophical position that only one router
  can be used for one html page / single page app and it is the top most
  app container object other than window.

  A bad ass router knows how to construct all the pieces of a page using
  @appConstructor. This includes all models, collections and views.

  It also assumes that each route has an associated top level views
  which becomes visible when you hit that route and all other become hidden
"""
module.exports = class BadassRouter extends Backbone.Router

  # Set logging on /off - Why? : Handy during dev to see flow of routes
  logging: off

  # Set to off if you don't to maintain route history
  history: on

  # Set to off if you don't want to use pushSate in child router
  pushState: on

  # Should almost always override pushStateRoot in child router
  pushStateRoot: '/'

  #
  loadOnJqueryReadyWithPageData: on

  # takes pageData to pre-load data into the SPA without ajax calls
  constructor: (pageData, callback) ->

    if @logging
      $log 'BadassRouter.ctor', @pageData, callback

    @pageData = pageData if pageData?

    app = @appConstructor pageData, callback
    @app = _.extend @app, app

    if @logging
      $log 'BadassRouter.app', @app

    @initialize = _.wrap @initialize, (fn, args) =>
      if @logging then $log "Router.init", @app, args
      fn.call @, args
      # wire up our 3rd party provider scripts to load only after our spa
      # had been initialized and constructed
      #@loadExternalProviders()

    @wrapRoutes()

    if @history
      Backbone.history.start pushState: @pushState, root: @pushStateRoot
      if @logging
        $log "History.pushState", @pushState, @pushStateRoot

    # Call backbone to correctly wire up & call Router.initialize
    Backbone.Router::constructor.apply @, arguments

  # construct all instances of models, collection & views for page
  appConstructor: (pageData, callback) ->
    throw new Error 'override appConstructor in child router'

  # load external providers like google analytics, user-voice etc.
  loadExternalProviders: ->
    throw new Error 'override loadExternalProviders in child router'

  # automatically wrap route handlers
  wrapRoutes: ->

    for route of @routes
      routeName = route.split('/')[0]  # routes may contain /:id etc.
      @[routeName].routeName = routeName
      @[routeName] = _.wrap @[routeName], (fn, args) =>
        if @logging then $log "Router.#{fn.routeName}"
        $(".route").hide()
        $("##{fn.routeName}").show()
        fn.call @, args

  # prefer trigger to always be true
  # pass false as second arg for false
  navTo: (route, trigger) ->
    trigger = true if !trigger?
    @navigate route, { trigger: trigger }
    $log 'navTo', route, 'trigger:', trigger

  # short hand to handle injection of pageData for pre-loading models
  setOrFetch: (model, data, opts) ->
    if data? then return model.set data
    opts = {} if !opts?
    opts.reset = true # backbone 1.0 so slow without this set
    model.fetch opts

  # short hand to handle injection of pageData for pre-loading collections
  resetOrFectch: (collection, data, opts) ->
    if data? then return collection.reset data
    opts = {} if !opts?
    opts.reset = true # backbone 1.0 so slow without this set
    collection.fetch opts