exports = {}


class exports.AdminRouter extends Backbone.Router

  routes:
    '':             'index'
    'skills':       'skills'
    'devs':         'devs'
    'companys':     'companys'
    'lead/:id':     'lead'
    'suggest/:id':  'suggest'

  initialize: (args) ->
    @page = args.page

  index: (args) ->
    $log 'Router.index'
    @hideshow '#leads'

  skills: (args) ->
    $log 'Router.skills'
    @hideshow '#skills'

  devs: (args) ->
    $log 'Router.devs'
    @hideshow '#devs'

  companys: (args) ->
    $log 'Router.companys'
    @hideshow '#companys'

  lead: (id) ->
    $log 'Router.lead'
    if @page.currentLead.id != id
      lead = _.find @page.leads.models, (m) -> m.id.toString() is id
      if !lead? then alert 'Lead doesnt exist with id: ' + id
      else
        @page.currentLead.set lead.attributes ## forces redraw
        $log 'currentLead', @page.currentLead.attributes
        @hideshow '#lead'

  suggest: (id) ->
    $log 'Router.suggest'

  hideshow: (selector) ->
    $('.main').hide()
    $(selector).show()




class exports.ReviewRouter extends Backbone.Router
  routes:
    '': 'index'
    ':id': 'review'
  initialize: (args) ->
    $log 'Router.init'
    @page = args.page
  review: (id) ->
    $log 'Router.review'
    if @page.currentLead.id != id
      lead = _.find @page.leads.models, (m) -> m.id.toString() is id
      if !lead? then alert 'Lead doesnt exist with id: ' + id
      else
        @page.currentLead.set lead.attributes ## forces redraw


module.exports = exports