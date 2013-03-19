exports = {}
M = require './Models'


class exports.AdminRouter extends Backbone.Router

  routes:
    '':             'index'
    'skills':       'skills'
    'devs':         'devs'
    'companys':     'companys'
    'suggest/:id':  'suggest'
    'new-request':  'requestForm'
    'request/:id':  'requestForm'


  initialize: (args) ->
    @page = args.page


  index: (args) ->
    $log 'Router.index'
    @hideshow '#requests'


  skills: (args) ->
    $log 'Router.skills'
    @hideshow '#skills'


  devs: (args) ->
    $log 'Router.devs'
    @hideshow '#devs'


  companys: (args) ->
    $log 'Router.companys'
    @hideshow '#companys'


  requestForm: (id) ->
    $log 'Router.requestForm', id
    if !id?
      @page.currentRequest.clean()
    else
      request = _.find @page.requests.models, (m) -> m.get('_id').toString() == id
      if !request? then return @navigate '#', true
      else
        @page.currentRequest.set request.attributes

    @page.requestFormView.render @page.currentRequest
    @hideshow '#requestForm'


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