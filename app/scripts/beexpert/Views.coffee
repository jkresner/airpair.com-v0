exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require './../shared/Views'

exports.ExpertView = SV.ExpertView

#############################################################################
##
#############################################################################

class exports.WelcomeView extends BB.BadassView
  el: '#welcome'
  tmpl: require './templates/Welcome'
  events: { 'click .track': 'track' }
  initialize: ->
    @e = addjs.events.expertLogin
    @e2 = addjs.events.expertWelcome
  render: ->
    if !@timer? then @timer = new addjs.Timer(@e.category).start()
    @$el.html @tmpl()
    trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
    setTimeout trackWelcome, 400
  track: (e) =>
    e.preventDefault()
    addjs.trackEvent @e.category, @e.name, @e.uri, @timer.timeSpent()
    setTimeout @oauthRedirect, 400
  oauthRedirect: ->
    window.location = "/auth/google?return_to=/be-an-expert&mixpanelId=#{mixpanel.get_distinct_id()}"


#############################################################################
##
#############################################################################

class exports.ConnectView extends BB.ModelSaveView
  el: '#connectForm'
  tmpl: require './templates/Connect'
  events:
    'click .save': 'save'
  initialize: -> # we call render explicitly, only need to once on page load
  render: ->
    @e = addjs.events.expertConnect
    @model.setFromUser @session
    @$el.html @tmpl @model.extend hasUsername: @mget('username')?
    @$(".btn-cancel").toggle @mget('_id')?
    @
  renderSuccess: (model, resp, opts) =>
    router.navigate '#info', { trigger: true }
    t = @model.get 'tags'
    if t? && t.length is 0 then @model.set 'tags', null
    addjs.trackEvent @e.category, @e.name, @model.get('name')
  getViewData: ->
    @model.extend updated: new Date()


#############################################################################
##
#############################################################################

class exports.InfoFormView extends BB.ModelSaveView
  el: '#infoForm'
  tmpl: require './templates/InfoForm'
  events: { 'click .save': 'save' }
  initialize: ->
    @e = addjs.events.expertInfo
    @firstRender = yes
    @$el.html @tmpl {}
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @$('input:radio').on 'click', @selectRB
    @listenTo @model, 'change', @render
  render: ->
    if !@timer? then @timer = new addjs.Timer(@e.category).start()
    return if @model.hasChanged('tags') && !@firstRender
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
    router.navTo 'thanks'
    addjs.trackEvent @e.category, @e.name, @model.get('name'), @timer.timeSpent()
    addjs.providers.mp.setPeopleProps isExpert : 'Y'
  getViewData: ->
    homepage: @elm('homepage').val()
    brief: @elm('brief').val()
    hours: @elm('hours').val()
    rate: @$("[name='rate']:checked").val()
    status: @$("[name='status']:checked").val()
    tags: @tagsInput.getViewData()


#############################################################################


module.exports = exports
