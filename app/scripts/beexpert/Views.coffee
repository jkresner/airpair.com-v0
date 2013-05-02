exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

exports.ExpertView = SV.ExpertView

#############################################################################
##
#############################################################################

class exports.ConnectFormView extends BB.ModelSaveView
  # logging: on
  el: '#connectForm'
  tmpl: require './templates/ConnectForm'
  events:
    'click .save': 'save'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @model.toJSON()
    @$(".save").toggle @model.get('username')?
    @$(".btn-cancel").toggle @model.get('_id')?
    @
  renderSuccess: (model, response, options) =>
    router.navigate '#info', { trigger: true }
    t = @model.get 'tags'
    if t? && t.length is 0 then @model.set 'tags', null
  getViewData: ->
    @model.toJSON()


class exports.InfoFormView extends BB.ModelSaveView
  logging: on
  el: '#infoForm'
  tmpl: require './templates/InfoForm'
  events:
    'click .save': 'save'
  initialize: ->
    @firstRender = yes
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @listenTo @model, 'change', @render
  render: ->
    if @model.hasChanged('tags') && !@firstRender then $log 'not rendering info'; return
    @setValsFromModel ['homepage','brief','hours']
    @$(":radio[value=#{@model.get('rate')}]").prop('checked',true).click()
    @$(":radio[value=#{@model.get('status')}]").prop('checked',true).click()
    @firstRender = no
    @
  selectRB: (e) ->
    rb = $(e.currentTarget)
    group = rb.parent()
    group.find("label").removeClass 'checked'
    rb.prev().addClass 'checked'
  renderSuccess: (model, response, options) =>
    router.navigate '#thanks', { trigger: true }
  getViewData: ->
    homepage: @$("[name='homepage']").val()
    hours: @$("[name='hours']").val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    brief: @$("[name='brief']").val()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports