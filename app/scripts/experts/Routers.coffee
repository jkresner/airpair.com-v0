exports = {}


class exports.ExpertsRouter extends Backbone.Router

  routes:
    ''            : 'list'
    'select/:id'  : 'select'
    'edit'        : 'edit'

  initialize: (args) ->
    @page = args.page

  list: ->
    # $log 'Router.list'
    @hideShow '#list'

  edit: ->
    # $log 'Router.edit'
    @hideShow '#edit'

  select: (id) ->
    # $log 'Router.select', id
    if !id?
      @page.selected.clearAndSetDefaults()
    else
      expert = _.find @page.experts.models, (m) -> m.get('_id').toString() == id
      if !expert? then return @navigate '#', true
      else
        @page.selected.set expert.attributes
    @navigate '#'

  edit: ->
    $log 'Router.edit', @page.selected.attributes
    @hideShow '#edit'

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()

module.exports = exports