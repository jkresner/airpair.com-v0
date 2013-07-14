exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

Handlebars.registerPartial "Expert", require './../shared/templates/Expert'
Handlebars.registerPartial "ExpertMini", require './../shared/templates/ExpertMini'
Handlebars.registerPartial "Suggestion", require './templates/Suggestion'

#############################################################################
## Shared across Expert Review + Experts View
#############################################################################

class exports.SuggestionView extends BB.BadassView
  className: 'suggestion'
  tmpl: require './templates/Suggestion'
  initialize: (args) ->
    @reviewForm = new exports.CustomerReviewFormView args
    @model.set requestId: @request.id
  render: ->
    d = @model.extend isCustomer: @request.isCustomer(@session)
    d.rates = @model.get('suggestedRate')[@request.get('pricing')]
    @$el.html @tmpl d
    # cust = @request.contact(0)
    # if @request.isCustomer @session
    #   @$('.customerReviewForm').append @reviewForm.render().el
    #   @$('.customerReviewForm').toggle !@mget('customerFeedback')?
    #   @$('.feedback').toggle @mget('customerFeedback')?
    @


#############################################################################
## Book
#############################################################################

class exports.BookSummaryView extends BB.BadassView
  el: '#summary'
  tmpl: require './templates/BookSummary'
  initialize: (args) ->
    @listenTo @order, 'change', @render
  render: ->
    @order.setTotal()
    @$el.html @tmpl @order.toJSON()
    @


class exports.BookExpertView extends BB.BadassView
  tmpl: require './templates/BookExpert'
  events:
    'change select': 'update'
  initialize: (args) ->
  render: ->
    @li = @model.lineItem @suggestion._id
    @$el.html @tmpl @li
    @elm('pricing').val @li.pricing
    @elm('qty').val @li.qty
    @
  update: ->
    @li = @model.lineItem @suggestion._id
    @li.type = @elm('pricing').val()
    @li.qty = parseInt( @elm('qty').val() )
    @li.unitPrice = @suggestion.suggestedRate[@li.pricing].total
    @li.total = @li.qty * @li.unitPrice
    @model.trigger 'change'
    @render()


class exports.BookView extends BB.ModelSaveView
  el: '#book'
  tmpl: require './templates/BookInfo'
  events:
    'click .pay': 'pay'
  initialize: (args) ->
    window.PAYPAL = require '/scripts/providers/paypal'
    @$el.html @tmpl()
    @embeddedPPFlow = new PAYPAL.apps.DGFlow trigger: 'submitBtn',type:'light'
    @summaryView = new exports.BookSummaryView order: @model
    @listenTo @request, 'change', @renderExperts
    @listenTo @model, 'change', @renderPay
  renderExperts: ->
    if @request.get('suggested')?
      @model.set requestId: @request.id, 'lineItems': []
      pricing = @request.get('pricing')
      @$('ul').html ''
      for s in @request.get('suggested')
        item = suggestion: s, qty: 0, total: 0, pricing: @request.get('pricing'), unitPrice: s.suggestedRate[pricing].total
        @model.get('lineItems').push item
        @$('ul').append( new exports.BookExpertView(suggestion:s,request:@request,model:@model).render().el )
    @
  renderPay: ->
    @$('#pay').toggle @mget('total') isnt 0
    @$('#selecthours').toggle @mget('total') is 0
    @
  pay: (e) ->
    e.preventDefault()
    if @model.get('total') is 0
      alert('please select at least one hour')
    else
      @save(e)
  getViewData: ->
    @model.attributes
  renderSuccess: (model, resp, opts) ->
    @$('#paykey').val resp.payKey
    @$('#submitBtn').click()


#############################################################################
## Review
#############################################################################


class exports.ExpertReviewFormView extends BB.EnhancedFormView
  el: '#expertReviewForm'
  tmpl: require './templates/ExpertReviewForm'
  viewData: ['expertRating', 'expertFeedback', 'expertStatus', 'expertComment', 'expertAvailability']
  events:
    'click .saveFeedback': 'save'
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @elm('expertStatus').on 'change', @toggleFormElements
    @enableCharCount 'expertFeedback'
    @setValsFromModel ['expertRating', 'expertStatus']
    @elm('expertStatus').trigger 'change'
    @
  toggleFormElements: =>
    @renderInputsValid()
    expertStatus = @elm('expertStatus').val()
    @$('.hideShowSave').toggle expertStatus != ''
    if expertStatus is 'available'
      @elm('expertComment').attr 'placeholder', "Comment to the customer on why they should book you for this airpair."
      if @elm('expertAvailability').val() is 'unavailable' then @elm('expertAvailability').val('')
    else if expertStatus is 'abstained'
      @elm('expertComment').attr 'placeholder', "Comment to the customer on why you don't want this airpair. E.g. Are you busy this week?"
      @elm('expertAvailability').val('unavailable').hide()
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.ExpertReviewDetailView extends BB.BadassView
  el: '#expertReviewDetail'
  tmpl: require './templates/ExpertReviewDetail'
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.ExpertReviewView extends BB.BadassView
  el: '#expertReview'
  tmpl: require './templates/ExpertReview'
  events:
    'click .edit': -> @render(true); false
  initialize: (args) ->
    @$el.html @tmpl()
    @reviewFormView = new exports.ExpertReviewFormView args
    @detailView = new exports.ExpertReviewDetailView args
  render: (editing) ->
    @editing = @model.get('expertFeedback') is undefined
    @editing = editing if editing?
    @reviewFormView.render() if @editing
    @reviewFormView.$el.toggle @editing
    @detailView.render() if !@editing
    @detailView.$el.toggle !@editing
    @


#############################################################################
##
#############################################################################


class exports.CustomerReviewFormView extends BB.ModelSaveView
  tmpl: require './templates/CustomerReviewForm'
  events: { 'click .saveFeedback': 'save' }
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @model.toJSON()
    @elm('customerRating').on 'change', @toggleUnwatedCheckbox
    @
  toggleUnwatedCheckbox: =>
    rating = parseInt @elm('customerRating').val()
    @$('.unwanted').toggle rating < 3
  getViewData: (e) ->
    d = @getValsFromInputs ['customerRating', 'customerFeedback']
    if @elm('unwanted').is(':checked') then d.expertStatus = 'unwanted'
    d
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes


class exports.CustomerReviewView extends BB.BadassView
  el: '#customerReview'
  tmpl: require './templates/Experts'
  initialize: (args) ->
  render: ->
    @$el.html @tmpl @request.toJSON()
    for s in @request.get('suggested')
      args = model: new M.CustomerReview(s), request: @request, session: @session
      @$('.suggested').append new exports.SuggestionView(args).render().el
    @


#############################################################################
##
#############################################################################


class exports.NotExpertOrCustomerView extends BB.BadassView
  el: '#notExpertOrCustomer'
  tmpl: require './templates/NotExpertOrCustomer'
  render: ->
    @$el.html @tmpl @request.extend authenticated: @session.authenticated(), tagsString: @request.tagsString()
    @


#############################################################################
##
#############################################################################


class exports.RequestInfoView extends BB.BadassView
  el: '#info'
  tmpl: require './templates/Info'
  render: ->
    hasAvailableExperts = false
    if @request.get('suggested')?
      for s in @request.get('suggested')
        if s.expertStatus is 'available' then hasAvailableExperts = true
    d =
      isCustomer: @request.isCustomer @session
      total: @hrTotal()
      hasAvailableExpert: hasAvailableExperts

    @$el.html @tmpl @request.extend(d)
    @
  hrTotal: -> #TODO remove from view and put into model
    t = @mget('budget')
    pricing = @mget('pricing')
    if pricing is 'private' then t = t+20
    if pricing is 'nda' then t = t+60
    t


class exports.RequestView extends BB.BadassView
  el: '#request'
  tmpl: require './templates/Request'
  initialize: (args) ->
    @$el.html @tmpl()
    @infoView = new exports.RequestInfoView args
    @anonView = new exports.NotExpertOrCustomerView args
    @customerReviewView = new exports.CustomerReviewView args
    expArgs = _.extend args, { model: new M.ExpertReview() }
    @expertReviewView = new exports.ExpertReviewView expArgs
    @listenTo @request, 'change', @render
  render: ->
    @infoView.render()
    meExpert = @request.suggestion @session.id
    # $log 'rendered', meExpert, @request.attributes.suggested
    if meExpert?
      @expertReviewView.model.set _.extend(meExpert, { requestId: @request.id })
      @expertReviewView.render()
    else if @request.isCustomer @session
      @customerReviewView.render()
    else
      @anonView.render()
    @



module.exports = exports