exports = {}


class exports.AdminRouter extends Backbone.Router
  routes:
    '': 'index'
    'lead/:id': 'lead'
    'suggest/:id': 'suggest'
  initialize: (args) ->
    @page = args.page
  index: (args) ->
    $log 'Router.index'
    @hideshow('#leads')
  lead: (id) ->
    $log 'Router.lead'
    if @page.currentLead.id != id
      lead = _.find @page.leads.models, (m) -> m.id.toString() is id
      if !lead? then alert 'Lead doesnt exist with id: ' + id
      else
        @page.currentLead.set lead.attributes ## forces redraw
        $log 'currentLead', @page.currentLead.attributes
        @hideshow('#lead')

  suggest: (id) ->
    $log 'Router.suggest'
  hideshow: (selector) ->
    $('.main').hide()
    $(selector).show()

module.exports = exports