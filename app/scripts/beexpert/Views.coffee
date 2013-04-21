exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

exports.ExpertView = SV.ExpertView

#############################################################################
##
#############################################################################

class exports.ConnectFormView extends BB.ModelSaveView
  logging: on
  el: '#connectForm'
  tmpl: require './templates/ConnectForm'
  events:
    'click .save': 'save'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    router.navigate '#info', { trigger: true }
  getViewData: ->
    @model.toJSON()


class exports.InfoFormView extends BB.ModelSaveView
  el: '#infoForm'
  tmpl: require './templates/InfoForm'
  viewData: ['brief']
  events:
    'click .save': 'save'
  initialize: ->
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @availabilityInput = new SV.AvailabiltyInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @listenTo @model, 'change', @render
  render: ->
    @setValsFromModel ['homepage','brief','hours']
    @$(":radio[value=#{@model.get('rate')}]").prop('checked',true).click()
    @$(":radio[value=#{@model.get('status')}]").prop('checked',true).click()
    # tagsInput + availabiltyInput will render automatically
    @
  selectRB: (e) ->
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    router.navigate '#thanks', { trigger: true }
  getViewData: ->
    hours: @$("[name='hours']").val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    brief: @$("[name='brief']").val()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports