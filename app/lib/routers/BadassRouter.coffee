# """

# """
# module.exports = class BadassRouter extends Backbone.Router

#   pushState: on
#   pushStateRoot: '/'    # Should always override in child router

#   # Set logging on /off
#   # Why? : During dev it's handy to see the flow of routes.
#   logging: off

#   # routes should always be defined / overridden in the child router
#   # for logging to work, Badass convention is to use functions instead
#   # of strings for the route handlers
#   routes:
#     '':             @index


#   constructor: (pageData, callback) ->

#     @app = appConstructor pageData, callback

#     if @logging
#       @enableLogging()

#     Backbone.history.start pushState: @pushState, root: @pushStateRoot

#     # Call backbone to correctly wire up & call Router.initialize
#     Backbone.Router::constructor.apply @, arguments

#   appConstructor: (pageData, callback) ->
#     throw new Error 'override appConstructor in child router'
#     if @app? then throw new Error '@app can only be constructed once'

#   index: (args) ->
#     $log 'Router.index'
#     @hideshow '#requests'

#   enableLogging: ->

#     for own route, fn of @routes
#       @[attr] = value

#     for route in @routes


#     @viewTypeName = @constructor.name

#     if @initialize?
#       @initialize = _.wrap @initialize, (fn, args) =>
#         $log "#{@viewTypeName}.init", args
#         fn.call @, args

#     if @render?
#       @render = _.wrap @render, (fn, args) =>
#         $log "#{@viewTypeName}.render", "model", @model, "collection", @collection
#         fn.call @, args

#     if @save?
#       @save = _.wrap @save, (fn, args) =>
#         $log "#{@viewTypeName}.save", args
#         fn.call @, args

#   showRoute: (routeName) ->
#     $(".route").hide()
#     $("#{routeName}").show()
