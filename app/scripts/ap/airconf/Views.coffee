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
    'click #promo .clickable': 'showPromo'
    'click .promocode': 'renderPromo'
    'click .retry': 'restorePromo'
    'submit form#payment-form': 'formHandler'
    'click .individual': -> @elm("name").val('Individual')

  initialize: (args) ->

  render: ->
    # pre-populate the user information form
    contact = @company.get('contacts')[0]
    if contact?
      @elm("name").val @company.get('name')
      @elm("fullName").val contact.fullName
      @elm("email").val contact.email
      @elm("twitter").val contact.twitter

    # do we need to gather credit card information?
    if !@page.get('hasCard')
      @renderStripe()()
    else
      @$('#haveCard').show()

    # populate the total on the buy button
    @$('.total').html @model.get('total')

    @

  renderStripe: ->
    _.once =>
      require '/scripts/providers/stripe.v2'
      Stripe.setPublishableKey @page.get('stripePK')
      $('#stripeRegister').show()

  formHandler: (e) =>
    # reset error message
    $('.payment-errors').text('')

    # prevent doubleclick
    $('#paybutton').html('Payment processing ...').prop('disabled', true)

    # log with analytics
    addjs.trackEvent("airconf", 'customerTryPayStripe', "/airconf-registration")

    # stop default behavior
    e.preventDefault()

    if !@page.get('hasCard')
      console.log 'i think i has a card'
      Stripe.card.createToken($('form#payment-form'), @stripeResponseHandler)
    else
      addjs.trackEvent "airconf", 'customerRegisteringWithSavedCard', "/airconf-registration"
      console.log "about to try saving"
      @save null

    false

  stripeResponseHandler: (status, response) =>
    if response.error # Show the errors on the form
      @$('.payment-errors').text response.error.message
      $('#paybutton').html('Pay for my ticket').prop('disabled', false)
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
    $('#promoresult').hide()
    $.post('/api/landing/airconf/promo', {code})
      .done (data) =>
        console.log 'valid promocode', data
        $('.promocodeMessage').html(data.message)
        $('promoresult').show()
        $('#paybutton').html(data.paybutton)
        @elm('promocode').removeClass('invalid')
        $('#ordertotalamount').html(data.cost)
        @model.set(total: data.cost, promocode: data.code)
        if !@page.get('hasCard') and data.cost is "0"
          $('.card-required').show()
          $('#payment-form input').attr('required','required')

      .fail (res) =>
        console.log 'invalid promocode', data
        console.log(res)
        data = JSON.parse(res.responseText)
        $('.promocodeMessage').html(data.message)
        $('promoresult').show()
        @elm('promocode').addClass('invalid').focus()

    $('#promo').hide()
    $('#promoresult').show()

  restorePromo: (e) ->
    $('#promo').show()
    $('#promoresult').hide()
    @elm('promocode').select()

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
