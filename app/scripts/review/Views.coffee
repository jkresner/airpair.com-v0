exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##  To render requests
#############################################################################


class exports.RequestCustomerSuggestionView extends BB.ModelSaveView
  tagName: 'li'
  tmpl: require './templates/CustomerSuggestion'
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
      @$('ul').append new exports.RequestCustomerSuggestionView(args).render().el
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
      if true
        @suggestionsView = new exports.RequestCustomerSuggestionsView(model: @model, session: @session).render().el
      else
        @$('#suggestions').html 'please leave your feedback'
    @
  hrTotal: ->
    tot = @model.get('budget')
    pricing = @model.get('pricing')
    if pricing is 'private' then tot = tot+20
    if pricing is 'nda' then tot = tot+60
    tot


Handlebars.registerPartial "Expert", require('./../shared/templates/Expert')


module.exports = exports