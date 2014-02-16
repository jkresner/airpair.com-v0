exports = {}
BB      = require './../../lib/BB'
M       = require './Models'
SV      = require './../shared/Views'

Handlebars.registerPartial "Links", require('./templates/Links')

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends BB.BadassView
  tagName: 'tr'
  className: 'expert'
  tmpl: require './templates/Row'
  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', => @$el.remove()
  render: ->
    @$el.html @tmpl _.extend @model.toJSON(), { hasLinks: @model.hasLinks() }
    @


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
  tmplLinks: require './templates/Links'
  viewData: ['name', 'email', 'gmail', 'pic', 'homepage', 'skills', 'rate']
  events:
    'click .save': 'save'
    'click .deleteExpert': 'destroy'
    'click .btn-gravatar': 'setGravatar'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: (model) ->
    @setValsFromModel ['name', 'email', 'gmail', 'pic', 'homepage', 'brief', 'hours']
    @$("img.pic").prop('src',@model.get('pic'))
    @$(":radio[value=#{@model.get('rate')}]").prop('checked',true).click()
    @$(":radio[value=#{@model.get('status')}]").prop('checked',true).click()
    @$(".links").html @tmplLinks @model.toJSON()
    @$(".btn-gravatar").toggle @model.get('gh')?
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    if @collection.length > 0
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
  destroy: ->
    m = @collection.findWhere(_id: @model.id)
    m.destroy()
    router.navTo '#list'
  setGravatar: (e)->
    @model.set 'pic', "//0.gravatar.com/avatar/#{@model.get('gh').gravatar_id}"
    false

module.exports = exports
