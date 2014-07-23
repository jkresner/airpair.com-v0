exports = {}
BB      = require 'BB'
M       = require './Models'
SV      = require '../../shared/Views'

#############################################################################
## Book
#############################################################################


""" JK: this is the worst view I've written in the whole app """
class exports.OrderView extends BB.ModelSaveView
  # logging: on
  el: '#order'
  events:
    'click .pay': 'pay'
    'click .promocode': 'renderPromo'
    'input [name=promocode]': -> @$('.promocode').show()
    'click .individual': -> @elm("name").val('Individual')
  initialize: (args) ->
    # @listenTo @model, 'change', @render
  render: ->
    if !@page.get('hasCard') then @renderStripe()
    else @$('#haveCard').show()

    @$('.total').html @model.get('total')
    # $log '@company', @company.attributes.contacts
    contact = @company.get('contacts')[0]
    if contact?
      @elm("name").val @company.get('name')
      @elm("fullName").val contact.fullName
      @elm("email").val contact.email
      @elm("twitter").val contact.twitter
    @
  renderStripe: ->
    return if @stripeRendered
    require '/scripts/providers/stripe.v2'
    @stripeRendered = true
    Stripe.setPublishableKey @page.get('stripePK')
    @$('#stripeRegister').show()
    @$form = @$('form')
    @$form.on 'submit', (e) =>
      e.preventDefault()
      @$('button').prop 'disabled', true  # Disable submitBtn to prevent repeat clicks
      Stripe.card.createToken @$form, @responseHandler
  responseHandler: (status, response) =>
    if response.error # Show the errors on the form
      @$('.payment-errors').text response.error.message
      @$('button').prop 'disabled', false
    else
      @model.set 'stripeCreate', { token: response.id, email: @elm("email").val() }
      addjs.trackEvent "airconf", 'customerTryPayStripe', "/airconf-registration"
      @save null
  renderPromo: ->
    code = @elm('promocode').val()
    $.post '/api/landing/airconf/promo',{code}, (data) =>
      @$('.promocodeMessage').html data.message
      if data.promoRate != @model.get('total')
        @model.set { total: data.promoRate, promocode: code }
        @$('.total').html @model.get('total')
        if data.promoRate is 0
          $('.card-required').show()
      @elm('promocode').val('')
  pay: (e) ->
    # Disable submitBtn to prevent repeat clicks
    @$('.pay').html('Payment processing ...').prop 'disabled', true
    addjs.trackEvent "airconf", 'customerTryPayStripe', "/airconf-registration"
    @save e
  getViewData: ->
    company = @model.get('company')
    companyViewData =
      name:    @elm("name").val()
      contact:
        fullName: @elm("fullName").val()
        email:    @elm("email").val()
        twitter:  @elm("twitter").val()
    if company?
      company.name = companyViewData.name
      company.contacts[0] = _.extend company.contacts[0], companyViewData.contact
      @model.set('company', company)
    else
      @model.set('company', companyViewData)
    # $log 'getViewData', @model.attributes
    @model.attributes
  renderSuccess: (model, resp, opts) =>
    router.navTo "thanks"



module.exports = exports
