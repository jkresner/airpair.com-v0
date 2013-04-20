exports = {}


class exports.ReviewRouter extends Backbone.Router

  routes:
    ''              : 'empty'
    ':id'           : 'view'

  initialize: (args) ->
    @page = args.page

  empty: ->
    window.location = '/dashboard'

  view: (id) ->
    if !id? then return window.location = '/dashboard'

    @page.request.set '_id': id
    @page.request.fetch()


module.exports = exports