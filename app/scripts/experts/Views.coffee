exports = {}
BB      = require './../../lib/BB'
M       = require './Models'
SV      = require './../shared/Views'

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends BB.BadassView
  tagName: 'tr'
  className: 'expert'
  tmpl: require './templates/Row'
  events:
    'click .deleteExpert': 'deleteExpert'
  initialize: ->
    @listenTo @model, 'change', @render
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
  events:
    'click .select': 'select'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models
     $list.append new exports.ExpertRowView( model: m ).render().el
    @$('.count').html @collection.models.length
    @
  select: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    expert = _.find @collection.models, (m) -> m.id.toString() == id
    @model.set expert.attributes


class exports.ExpertView extends BB.ModelSaveView
  el: '#edit'
  tmpl: require './templates/Expert'
  tmplLinks: require './../shared/templates/DevLinks'
  viewData: ['name', 'email', 'gmail', 'pic', 'homepage', 'skills', 'rate']
  events:
    'click .save': 'save'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: (model) ->
    @setValsFromModel ['name', 'email', 'gmail', 'pic', 'homepage', 'brief', 'hours']
    @$(":radio[value=#{@model.get('rate')}]").prop('checked',true).click()
    @$(":radio[value=#{@model.get('status')}]").prop('checked',true).click()
    @$(".links").html @tmplLinks @model.toJSON()
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    m = @collection.findWhere(_id: model.id)
    m.set model.attributes
    m.trigger 'change' # for the expert row to re-render
  getViewData: ->
    pic: @elm('pic').val()
    homepage: @elm('homepage').val()
    brief: @elm('brief').val()
    hours: @elm('hours').val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    tags: @tagsInput.getViewData()

module.exports = exports
