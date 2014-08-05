exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'

Handlebars.registerPartial "Expert", require '../../shared/templates/Expert'
Handlebars.registerPartial "ExpertMini", require '../../shared/templates/ExpertMini'
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


class exports.ThankYouView extends BB.ModelSaveView
  el: '#thankyou'
  tmpl: require './templates/ThankYou'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl { requestId: @model.id }


class exports.OrderView extends BB.ModelSaveView
  el: '#order'
  tmpl: require './templates/BookSummary'
  events:
    'click .pay': 'pay'
  initialize: (args) ->
    @listenTo @model, 'change', @render
    @listenTo @credit, 'change', @render
  render: ->
    console.log "credit", @credit
    @model.setTotal()
    @$('#summary').html @tmpl @model.toJSON()
    @$('#pay').toggle @mget('total') isnt 0
    @isStripeMode = @mget('paymentMethod')? && @mget('paymentMethod').type is 'stripe'
    if @isStripeMode
      @$('#pay').html('<a class="pay payStripe button" href="#">Confirm hours</a><p>Your credit card on file will be charged</p>')
      @$('#pay').addClass('stripe')
    @
  pay: (e) ->
    if @model.get('total') is 0
      e.preventDefault()
      alert('please select at least one hour')
    else
      if mixpanel? && mixpanel.get_property? && mixpanel.get_property('utm_source')?
        utm_values =
          utm_source: mixpanel.get_property('utm_source')
          utm_medium: mixpanel.get_property('utm_medium')
          utm_term: mixpanel.get_property('utm_term')
          utm_content: mixpanel.get_property('utm_content')
          utm_campaign: mixpanel.get_property('utm_campaign')

        @model.set('utm', utm_values)

      eventName = 'customerTryPayPaypal'
      if @isStripeMode
        eventName = 'customerTryPayStripe'
        # Disable submitBtn to prevent repeat clicks
        @$('.payStripe').html('Payment processing ...').prop 'disabled', true

      addjs.trackEvent "request", eventName, "/review/book/#{@model.get('requestId')}"

      @save(e)
    false
  getViewData: ->
    @model.attributes
  renderSuccess: (model, resp, opts) =>
    if @isStripeMode
      router.navTo "#thankyou/#{router.app.request.id}"
    else
      @$('#paykey').val model.attributes.payment.payKey
      @$('#submitBtn').click()



class exports.BookExpertView extends BB.BadassView
  className: 'bookableExpert'
  tmpl: require './templates/BookExpert'
  events:
    'change select': 'update'
  initialize: (args) ->
  render: ->
    @li = @model.lineItem @suggestion._id
    @$el.html @tmpl @li
    @elm('type').val @li.type
    @elm('qty').val @li.qty
    @
  update: ->
    @li.type = @elm('type').val()
    @li.qty = parseInt( @elm('qty').val() )
    @li.unitPrice = @suggestion.suggestedRate[@li.type].total
    @li.total = @li.qty * @li.unitPrice
    @model.trigger 'change'
    @render()


class exports.BookView extends BB.BadassView
  el: '#book'
  tmpl: require './templates/BookInfo'
  initialize: (args) ->
    @$el.html @tmpl useSandbox: !@isProd
    window.PAYPAL = require '/scripts/providers/paypal'
    @embeddedPPFlow = new PAYPAL.apps.DGFlow trigger: 'submitBtn',type:'light'
    @orderView = new exports.OrderView model: @model, credit: @credit
    @listenTo @request, 'change', @render
    @listenTo @model, 'change', =>
      @$('#selecthours').toggle @mget('total') is 0
  render: ->
    if @request.get('suggested')?
      @model.setFromRequest @request
      $ul = @$('ul').html('')
      for li in @model.get('lineItems')
        $ul.append new exports.BookExpertView(suggestion:li.suggestion,model:@model).render().el
    @


#############################################################################
## Review
#############################################################################

# class exports.ExpertPaymentSettingsView extends BB.ModelSaveView
#   el: '#expertReviewForm'
#   tmpl: require './templates/ExpertReviewForm'
#   viewData: ['expertRating', 'expertFeedback', 'expertStatus', 'expertComment', 'expertAvailability']
#   events:
#     'click .saveFeedback': 'saveFeedback'
#   initialize: (args) ->
#     @listenTo @settings, 'change', render()
#   render: ->
#     @


class exports.ExpertReviewFormView extends BB.EnhancedFormView
  el: '#expertReviewForm'
  tmpl: require './templates/ExpertReviewForm'
  viewData: [ 'expertStatus', 'expertComment',
    'expertAvailability','payPalEmail'] # 'expertRating', 'expertFeedback',
  events:
    'click .saveFeedback': 'saveFeedback'
    'input textarea': 'enableSubmit'
  initialize: (args) ->
    @listenTo @settings, 'change:paymentMethod', => @renderPayPalEmail()
  render: ->
    # $log 'render', @model.get('suggestedRate'), @request.attributes
    expertRate = @model.get('suggestedRate')[@request.get('pricing')].expert
    @$el.html @tmpl @model.extend({owner:@request.get('owner'),expertRate})
    @elm('expertStatus').on 'change', @toggleFormElements
    # @enableCharCount 'expertFeedback'
    @setValsFromModel ['expertRating', 'expertStatus']
    @renderPayPalEmail()
    @elm('expertStatus').trigger 'change'
    conf = =>
      if @elm('expertStatus').val() is 'available'
        @$('.saveFeedback').html "I confirm $#{expertRate}/hr"
    @$('.saveFeedback').hover conf, -> $(@).html 'Submit'
  renderPayPalEmail: ->
    pp = @settings.paymentMethod('paypal')
    payPalEmail = if pp? then pp.info.email
    if payPalEmail?
      @elm('payPalEmail').val payPalEmail
  toggleFormElements: =>
    @renderInputsValid()
    status = @elm('expertStatus').val()
    @$('.hideShowSave').toggle status != ''
    @$('.hideShowAvailable').hide()
    if status is 'available'
      @elm('expertComment').attr 'placeholder', "Comment to the customer on why they should book you for this airpair."
      if @elm('expertAvailability').val() is 'unavailable'
        @elm('expertAvailability').val('')
        @elm('expertComment').val('')
      @$('.hideShowAvailable').show()
    else
      @elm('expertAvailability').val('unavailable').hide()
      if status is 'abstained'
        @elm('expertComment').attr 'placeholder', 'Comment on why you do not want this AirPair'
      if status is 'busy'
        @elm('expertComment').attr 'placeholder', 'Comment on when you will be free next'
      if status is 'underpriced'
        @elm('expertComment').attr 'placeholder', 'Comment on how much more you would like, e.g. "$30/hr more"'
  saveFeedback: (e) ->
    isAvailable = @elm('expertStatus').val() is 'available'
    if isAvailable && @elm('payPalEmail').val().length < 4
      @renderInputValid @elm('payPalEmail'), 'You must supply your PayPal email address'
      alert 'You must supply your PayPal email address'
    else
      # Disable submitBtn to prevent repeat clicks
      @$('.saveFeedback').html('Submitting ...').prop 'disabled', true
      @save(e)
    false
  renderSuccess: (model, resp, options) =>
    @request.set model.attributes
  enableSubmit: (e) ->
    @$('.saveFeedback').html('Submit').prop 'disabled', false


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
    @listenTo @settings, 'change', => @render()
  render: (editing, selfReview) ->
    meExpert = @request.suggestion @session.id
    if meExpert? || selfReview
      @editing = @model.get('expertComment') is undefined
      @editing = editing if editing?
      @reviewFormView.render() if @editing
      @reviewFormView.$el.toggle @editing
      @detailView.render() if !@editing
      @detailView.$el.toggle !@editing
      @$el.show() if @$el?
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
    for s in @request.sortedSuggestions() when s.expertStatus != 'waiting'
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

    isIndividual = @request.get('company').name == 'Individual' ||
      @request.get('company').about.indexOf('Individual') == 0

    status = @request.get('status')

    reqStatus = 'in-progress'
    if status is 'received' || status is 'holding' || status is 'waiting' || status is 'review'
      reqStatus = 'open'
    if status is 'scheduling' || status is 'scheduled'
      reqStatus = 'already scheduled'
    if status is 'canceled' || status is 'completed' || status is 'consumed'
      reqStatus = 'closed'

    d =
      createdDate: @request.createdDateString()
      createdAgo: moment(@request.createdDate()).fromNow()
      isByIndividual: isIndividual
      isCustomer: @request.isCustomer @session
      meExpert: @request.suggestion @session.id
      total: @hrTotal()
      hasAvailableExpert: hasAvailableExperts
      reqStatus: reqStatus

    d.associatedWithRequest = d.meExpert || d.isCustomer

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
    requestId = @request.id
    @infoView.render()
    meExpert = @request.suggestion @session.id
    # $log 'rendered', meExpert, @request.attributes.suggested
    if @request.isCustomer @session
      @customerReviewView.render()
    else if meExpert?
      @expertReviewView.model.set _.extend(meExpert, { requestId } )
      @expertReviewView.render()
    else if @session.authenticated()
      @expert.requestId = requestId
      @expert.fetch success: (m,r) =>
        if m.id?
          sug = { expert: m.attributes, suggestedRate: m.attributes.suggestedRate, requestId }
          @expertReviewView.model.set sug
          @expertReviewView.render true, true
        else
          @anonView.render()
    else
      @anonView.render()
    @



module.exports = exports
