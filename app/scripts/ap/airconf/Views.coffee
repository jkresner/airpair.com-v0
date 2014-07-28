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
    'click #promo .clickable': 'showPromo'
    'click .promocode': 'renderPromo'
    'click .retry': 'restorePromo'
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

  showPromo: ->
    $('#promo .clickable').hide()
    $('#promoform')
      .show()
      .find('input').focus()

  renderPromo: ->
    code = @elm('promocode').val()
    $.post('/api/landing/airconf/promo', {code})
      .done (data) =>
        $('.promocodeMessage').html(data.message)
        $('#paybutton').html(data.paybutton)
        @elm('promocode').removeClass('invalid')
        $('#ordertotalamount').html(data.cost)
        @model.set(total: data.cost, promocode: data.code)
        if data.cost is "0"
          $('.card-required').show()
          $('#payment-form input').attr('required','required')
      .fail (res) =>
        console.log(res)
        data = JSON.parse(res.responseText)
        $('.promocodeMessage').html(data.message)
        @elm('promocode').addClass('invalid').focus()

    $('#promo').hide()
    $('#promoresult').show()

  restorePromo: (e) ->
    $('#promo').show()
    $('#promoresult').hide()
    @elm('promocode').select()

  pay: (e) ->
    # Disable submitBtn to prevent repeat clicks
    @$('.pay').html('Payment processing ...').prop 'disabled', true
    addjs.trackEvent "airconf", 'customerTryPayStripe', "/airconf-registration"
    @save e

  getViewData: ->
    company = @model.get('company')
    company.name = @elm("name").val()
    company.contacts[0] =
        fullName: @elm("fullName").val()
        email:    @elm("email").val()
        twitter:  @elm("twitter").val()
    @model.set { company }
    # $log 'getViewData', @model.attributes
    @model.attributes
  renderSuccess: (model, resp, opts) =>
    router.navTo "thanks"



module.exports = exports
