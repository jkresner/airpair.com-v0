""" BadassView adds two basic bits of functionality to a normal Backbone.View
    1) Auto-logging on invocation of initialize, render & save
    2) Auto setting passed in constructor args as attributes on the view instance
"""
module.exports = class BadassView extends Backbone.View

  # Set logging on /off
  # Why? : During dev it's really handing to see the flow of your views
  #        function calls and confirm you don't have extra listers firing etc.
  logging: off

  # Set autoSetConstructorArgs on /off
  # Why? : Often with bigger apps where views are associated with multiple
  #        models /collections you have to write left hand right hand assignment
  #        in initialize, this just accepts the convention that any key /value
  #        passed into the constructor gets set like backbone does with the
  #        'model' and 'collection' attributes.
  autoSetConstructorArgs: on


  constructor: (args) ->

    if @autoSetConstructorArgs
      for own attr, value of args
        @[attr] = value

    if @logging
      @turnOnLogging()

    # Calls backbone to correctly wire up & calls View.initialize
    Backbone.View::constructor.apply(@, arguments)


  turnOnLogging: ->
    @viewTypeName = @constructor.name

    if @initialize?
      @initialize = _.wrap @initialize, (fn, args) ->
        $log "#{@viewTypeName}.init", args
        fn.call @, args

    if @render?
      @render = _.wrap @render, (fn, args) ->
        $log "#{@viewTypeName}.render", args
        fn.call @, args

    if @save?
      @save = _.wrap @save, (fn, args) ->
        $log "#{@viewTypeName}.save", args
        fn.call @, args

    if @renderError?
      @renderError = _.wrap @renderError, (fn, args) ->
        $log "#{@viewTypeName}.renderError", args
        fn.call @, args

    if @renderSuccess?
      @renderSuccess = _.wrap @renderSuccess, (fn, args) ->
        $log "#{@viewTypeName}.renderSuccess", args
        fn.call @, args
