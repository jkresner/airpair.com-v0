exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends BB.BadassView
  logging: on
  tagName: 'tr'
  className: 'expert'
  tmpl: require './templates/Row'
  events: { 'click .deleteExpert': 'deleteExpert' }
  initialize: -> @model.on 'change', @render, @
  render: ->
    d = (_.extend @model.toJSON(), { hasLinks: @model.hasLinks() } )
    @$el.html @tmpl d
    @
  deleteExpert: ->
    $log 'deleting', @model.attributes
    @model.destroy()
    @$el.remove()


class exports.ExpertsView extends Backbone.View
  el: '#experts'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models
     $list.append new exports.ExpertRowView( model: m ).render().el
    @$('.count').html @collection.models.length
    @



# class exports.DevFormView extends BB.ModelSaveView
#   el: '#devFormView'
#   tmpl: require './templates/DevForm'
#   async: off  # async off because we want skills objects back from server
#   viewData: ['name','email','gmail','pic', 'homepage', 'gh', 'so', 'bb', 'in', 'other', 'skills', 'rate']
#   events: { 'click .save': 'save' }
#   initialize: ->
#   render: (model) ->
#     if model? then @model = model
#     tmplData = _.extend @model.toJSON(), { skillsSoIds: @model.skillSoIdsList() }
#     @$el.html @tmpl tmplData
#     @
#   renderSuccess: (model, response, options) =>
#     @$('.alert-success').fadeIn(800).fadeOut(5000)
#     @collection.add model
#     @render new M.Dev()

# class exports.DevsView extends DataListView
#   el: '#devs'
#   tmpl: require './templates/Devs'
#   initialize: (args) ->
#     @$el.html @tmpl()
#     @formView = new exports.DevFormView( model: new M.Dev(), collection: @collection ).render()
#     @collection.on 'reset add remove filter', @render, @
#   render: ->
#     $tbody = @$('tbody').html ''
#     for m in @collection.models
#       $tbody.append new exports.DevRowView( model: m ).render().el
#     @

exports.ExpertView = Shared.ExpertView


module.exports = exports