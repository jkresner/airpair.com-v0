exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'

#############################################################################
##  To render all tags for admin
#############################################################################

class exports.TagEditView extends BB.ModelSaveView
  tmpl: require './templates/TagEdit'
  viewData: ['name','short','desc','tokens']
  events:
    'click .save': 'save'
    'click .cancel': -> @remove()
  initialize: ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  renderSuccess: (model,resp,options) =>
    @remove()


class exports.TagRowView extends BB.BadassView
  className: 'tag label'
  tmpl: require './templates/Row'
  events:
    'click a.edit': 'showTagDetail'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  showTagDetail: (e) ->
    #e.preventDefault()
    @$el.append new exports.TagEditView(model: @model).render().el
    false


class exports.TagsView extends BB.BadassView
  el: '#tags'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.html ''
    for m in @collection.models
      @$el.append new exports.TagRowView( model: m ).render().el
    @$('.tag a').popover({})
    @


#############################################################################
##  Autocomplete and add new tag views
#############################################################################

class exports.TagNewForm extends SV.TagNewForm

class exports.TagsInputView extends SV.TagsInputView


module.exports = exports
