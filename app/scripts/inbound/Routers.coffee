exports = {}


class exports.InboundRouter extends Backbone.Router

  routes:
    ''             : 'list'
    'request/:id'  : 'edit'
    'closed'       : 'closed'
    'canceled'     : 'canceled'

  initialize: (args) ->
    @page = args.page

    @page.experts.on 'sync', => @navigate 'request/514d6386a521340200000066', { trigger: true }

  list: ->
    $log 'Router.list'
    @hideShow '#list'

  edit: (id) ->
    $log 'Router.edit'

    if !id?
      @page.selected.clearAndSetDefaults()
    else
      d = _.find @page.requests.models, (m) -> m.get('_id').toString() == id
      if !d? then return @navigate '#', true
      else
        @page.selected.set d.attributes

    @hideShow '#edit'

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()

module.exports = exports