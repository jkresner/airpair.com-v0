exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  To render requests
#############################################################################


class exports.SuggestionForExpertView extends BB.ModelSaveView
  tmpl: require './templates/SuggestionForExpert'
  events:
    'click .saveFeedback': 'save'
  initialize: (args) ->
    @model.set requestId: @request.get('_id'), custPic: @request.get('company').contacts[0].pic
  render: ->
    @$el.html @tmpl @model.extend { isWaiting: @model.get('status') is 'waiting' }
    @$('[name="expertStatus"]').on 'change', @toggleSaveButton
    @
  getViewData: (e) ->
    d = @getValsFromInputs ['expertRating', 'expertFeedback', 'expertStatus', 'expertComment', 'expertAvailability']
    d
  toggleSaveButton: =>
    expertStatus = @$('[name="expertStatus"]').val()
    $log 'expertStatus', expertStatus
    @$('.hideShowSave').toggle expertStatus != ''
    if expertStatus is 'available'
      @$('[name="expertComment"]').attr 'placeholder', "Leave a comment for the customer on why they should pick you for this airpair."
    else if expertStatus is 'abstained'
      @$('[name="expertComment"]').attr 'placeholder', "Leave a comment for the customer on why you won't take this airpair. E.g. you're not available ..."
      @$('[name="expertAvailability"]').hide()
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.SuggestionForCustomerView extends BB.ModelSaveView
  tagName: 'li'
  tmpl: require './templates/SuggestionForCustomer'
  events:
    'click .saveFeedback': 'save'
  initialize: (args) ->
    @model.set requestId: @request.get('_id'), custPic: @request.get('company').contacts[0].pic
  render: ->
    @$el.html @tmpl @model.toJSON()
    @$('[name="customerRating"]').on 'change', @toggleUnwatedCheckbox
    @
  getViewData: (e) ->
    d = @getValsFromInputs ['customerRating', 'customerFeedback']
    if @$('[name="unwanted"]').is(':checked') then d.expertStatus = 'unwanted'
    $log 'saving cust feedback yeah', d
    d
  toggleUnwatedCheckbox: =>
    rating = parseInt @$('[name="customerRating"]').val()
    @$('.unwanted').toggle rating < 3
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.RequestCustomerSuggestionsView extends BB.BadassView
  el: '#suggestions'
  tmpl: require './templates/CustomerSuggestions'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    for s in @model.get('suggested')
      args = model: new M.Suggestion(s), request: @model
      @$('ul').append new exports.SuggestionForCustomerView(args).render().el
    @


class exports.RequestView extends BB.BadassView
  el: '#request'
  tmpl: require './templates/Info'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    if @model.get('company')?
      isOwner = @model.get('userId') == @session.get('_id')
      tmplData = _.extend @model.toJSON(), { isOwner: isOwner, total: @hrTotal() }
      @$el.html @tmpl tmplData
      if isOwner
        @suggestionsView = new exports.RequestCustomerSuggestionsView(model: @model, session: @session).render().el
      else
        s = _.find @model.get('suggested'), (m) => m.expert.userId == @session.get('_id')
        if !s? then @$('#suggestions').html 'Not the expert or customer?'
        args = model: new M.Suggestion(s), request: @model
        @$('#suggestions').append new exports.SuggestionForExpertView(args).render().el
    @
  hrTotal: ->
    tot = @model.get('budget')
    pricing = @model.get('pricing')
    if pricing is 'private' then tot = tot+20
    if pricing is 'nda' then tot = tot+60
    tot


Handlebars.registerPartial "Expert", require('./../shared/templates/Expert')
Handlebars.registerPartial "ExpertMini", require('./../shared/templates/ExpertMini')

module.exports = exports