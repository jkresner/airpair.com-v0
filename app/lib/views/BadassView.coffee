""" BadassView adds two basic bits of functionality to a normal Backbone.View
    1) Auto-logging on invocation of initialize, render & save
    2) Auto set constructor args as attributes on the view instance
    3) Scoped element lookup based on name attribute instead of id
"""
module.exports = class BadassView extends Backbone.View

  # Set logging on /off
  # Why? : During dev it's handy to see the flow your views execute in
  #        to confirm you don't have extra listeners firing etc.
  logging: off

  # Set autoSetConstructorArgs on /off
  # Why? : Often with bigger apps views are associated with multiple
  #        models /collections and you tend to write LHRH (left hand,
  #        right hand) assignment in initialize. autoSetConstructorArgs
  #        is a convention that any key /values passed to the constructor
  #        gets set like 'model' & 'collection' in default backbone.
  autoSetConstructorArgs: on


  constructor: (args) ->

    # allow us to autoSetConstructorArgs via instance constructor
    if args? && args.autoSetConstructorArgs?
      @autoSetConstructorArgs = args.autoSetConstructorArgs

    if @autoSetConstructorArgs
      for own attr, value of args
        @[attr] = value

    if @logging
      @enableLogging()

    # Call backbone to correctly wire up & call View.initialize
    Backbone.View::constructor.apply(@, arguments)


  enableLogging: ->

    # Get the class name of the child view, like "TeasView"
    # So we can use this name in logging to distinguish the view
    @viewTypeName = @constructor.name

    if @initialize?
      @initialize = _.wrap @initialize, (fn, args) =>
        $log "#{@viewTypeName}.init", args
        fn.call @, args

    if @render?
      @render = _.wrap @render, (fn, args) =>
        $log "#{@viewTypeName}.render", "model", @model, "collection", @collection
        fn.call @, args

    if @save?
      @save = _.wrap @save, (fn, args) =>
        $log "#{@viewTypeName}.save", args
        fn.call @, args

  # Want to stop referring to elements by id
  # Use name attribute instead
  # + be strict about only looking inside the view's scope
  elm: (attr) ->
    @$("[name='#{attr}']")

  mget: (attr) ->
    @model.get(attr)