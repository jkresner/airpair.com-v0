exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  To render requests rows for admin
#############################################################################

class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'requestRow'
  tmpl: require './templates/Row'
  render: ->
    @$el.html @tmpl @tmplData()
    @
  tmplData: ->
    d = @model.toJSON()
    # $log 'RequestRowView.tmplData', d
    _.extend d, {
      contactName:        d.company.contacts[0].fullName
      contactPic:         d.company.contacts[0].pic
      contactEmail:       d.company.contacts[0].email
      createdDate:        @model.createdDateString()
      suggestedCount:     d.suggested.length
      suggestedFitCount:  _.filter(d.suggested, (s) -> s.status is 'chosen').length
      callCount:          d.calls.length
      callCompleteCount:  _.filter(d.calls, (s) -> s.status is 'complete').length
    }


class exports.RequestsView extends BB.BadassView
  el: '#requests'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @listenTo @collection, 'sync', @render # filter sort
  render: ->
    @$el.html @tmpl( count: @collection.length )
    for m in @collection.models
      sts = m.get('status')
      @$("##{sts} tbody").append new exports.RequestRowView( model: m ).render().el
    @


#############################################################################
##  To edit request
#############################################################################


class exports.RequestFormInfoView extends BB.BadassView
  logging: on
  el: '#reqInfo'
  tmpl: require './templates/RequestFormInfo'
  initialize: ->
    @$el.html @tmpl @model.toJSON()
    @tagsInput = new SV.TagsInputView model: @model, collection: @tags
    @listenTo @model, 'change', @render
  render: ->
    @$('#reqStatus').val @model.get 'status'
    @$('#reqStatus').on 'change', =>
      @$('#canceled-control-group').toggle @$('#reqStatus').val() == 'canceled'
      @$('#incomplete-control-group').toggle @$('#reqStatus').val() == 'incomplete'
    @


# class exports.RequestFormSuggestionsView extends BB.BadassView
#   #logging: on
#   el: '#reqSuggestions'
#   tmpl: require './templates/RequestFormSuggestions'
#   mailTmpl: require './../../mail/developerMatched'
#   events:
#     'click .suggestDev': 'add'
#     'click .deleteSuggested': 'remove'
#     'click a.mailMatched': 'sendMatchedMail'
#   initialize: ->
#     @listenTo @collection, 'sync', @render
#     @listenTo @model, 'change', @render
#   render: ->
#     tmplData = _.extend @model.toJSON(), { devs: @collection.toJSON() }
#     #$log 'render suggestions', @, @$el, @tmpl, tmplData
#     @$el.html @tmpl tmplData
#     @
#   add: (e) ->
#     if @$('#reqDev').val() == '' then alert 'select a dev'; return false
#     # todo, check for duplicates
#     @model.get('suggested').push
#       status: 'awaiting'
#       events: [{ 'created': new Date() }]
#       dev: { _id: @$('#reqDev').val(), name: @$('#reqDev option:selected').text() }
#       availability: []
#       comment: ''
#     @parentView.save e
#   remove: (e) ->
#     suggestionId = $(e.currentTarget).data 'id'
#     toRemove = _.find @model.get('suggested'), (d) -> d._id == suggestionId
#     $log 'suggestRemove', suggestionId, toRemove
#     @model.set 'suggested', _.without( @model.get('suggested'), toRemove )
#     @parentView.save e
#   sendMatchedMail: (e) ->
#     e.preventDefault()
#     devId = $(e.currentTarget).data 'id'
#     skillList = @model.skillSoIdsList()
#     developers = _.pluck @model.get('suggested'), 'dev'
#     dev = _.find developers, (d) -> d._id == devId
#     companyId = @model.get 'companyId',
#     $log 'companyId', companyId, @companys.models, @model
#     company = @companys.findWhere _id: companyId
#     #$log 'company', company
#     mailtoAddress = "#{dev.name}%20%3c#{dev.email}%3e"
#     body = @mailTmpl dev_name: dev.name, entrepreneur_name: company.get('contacts')[0].fullName, leadId: @model.get('_id')
#     window.open "mailto:#{mailtoAddress}?subject=airpair - Help an entrepreneur with #{skillList}?&body=#{body}"


# class exports.RequestFormCallsView extends BB.BadassView
#   initialize: ->
#     @listenTo @model, 'change', @render
#   render: ->


class exports.RequestFormView extends BB.ModelSaveView
  logging: on
  async: off
  el: '#requestForm'
  tmpl: require './templates/RequestForm'
  viewData: ['status','tags','brief','canceledReason']
  # mailTmpl: require './../../mail/developersContacted'
  events:
    'click #mailDevsContacted': 'sendDevsContacted'
    'click .save': 'save'
    # 'click .delete': 'deleteRequest'
  initialize: ->
    @$el.html @tmpl()
    @infoView = new exports.RequestFormInfoView model: @model, tags: @tags, parentView: @
    # @suggestionsView = new exports.RequestFormSuggestionsView model: @model, collection: @devs, companys: @companys, parentView: @
    # @callsView = new exports.RequestFormCallsView model: @model, parentView: @
  renderSuccess: (model, response, options) =>
    @$('.alert-success').fadeIn(800).fadeOut(5000)
    # @model.set model.attributes
    @collection.fetch()
  # getViewData: ->
  #   d = @getValsFromInputs @viewData
  #   d
  # sendDevsContacted: (e) ->
  #   e.preventDefault()
  #   cid = @model.get 'companyId'
  #   company = _.find @companys.models, (m) -> m.get('_id') == cid
  #   customer = company.get('contacts')[0]
  #   # $log 'sendDevsContacted', customer, cid
  #   mailtoAddress = "#{customer.fullName}%20%3c#{customer.email}%3e"
  #   body = @mailTmpl entrepreneur_name: customer.name, leadId: @model.id
  #   window.open "mailto:#{mailtoAddress}?subject=airpair - We've got you some devs!&body=#{body}"
  # deleteRequest: ->
  #   model.destroy()
  #   @collection.fetch()
  #   router.naviate '#', false
  #   false

Handlebars.registerPartial "RequestSet", require('./templates/RequestSet')

module.exports = exports