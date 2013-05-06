exports = {}


class exports.ReviewRouter extends Backbone.Router

  routes:
    ''              : 'empty'
    ':id'           : 'view'

  initialize: (args) ->
    @page = args.page

  empty: ->
    $log 'Router.empty'
    window.location = '/dashboard'

  view: (id) ->
    $log 'view', id
    if !id? then return window.location = '/dashboard'

    @page.request.set '_id': id
    @page.request.fetch { error: @empty }


module.exports = exports