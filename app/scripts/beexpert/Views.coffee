exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

exports.ExpertView = SV.ExpertView

#############################################################################
##
#############################################################################

class exports.WelcomeView extends BB.BadassView
  el: '#welcome'
  tmpl: require './templates/Welcome'
  render: -> @$el.html @tmpl()

#############################################################################
##
#############################################################################

class exports.ConnectView extends BB.ModelSaveView
  logging: on
  el: '#connectForm'
  tmpl: require './templates/Connect'
  events:
    'click .save': 'save'
  initialize: -> # we call render explicitly, only need to once on page load
  render: ->
    @model.setFromUser @session
    @$el.html @tmpl @model.extend hasUsername: @mget('username')?
    @$(".btn-cancel").toggle @mget('_id')?
    @
  renderError: (model, resp, opts) =>
    $log 'renderError'
  renderSuccess: (model, resp, opts) =>
    console.log 'renderSuccess'
    router.navigate '#info', { trigger: true }
    t = @model.get 'tags'
    if t? && t.length is 0 then @model.set 'tags', null
  getViewData: ->
    @model.extend updated: new Date()


#############################################################################
##
#############################################################################

class exports.InfoFormView extends BB.ModelSaveView
  logging: on
  el: '#infoForm'
  tmpl: require './templates/InfoForm'
  events: { 'click .save': 'save' }
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
    homepage: @elm('homepage').val()
    brief: @elm('brief').val()
    hours: @elm('hours').val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports