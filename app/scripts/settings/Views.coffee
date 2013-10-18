exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##
#############################################################################


class exports.StripeRegisterView extends BB.BadassView
  el: '#stripeRegister'
  tmpl: require './templates/StripeRegister'
  initialize: (args) ->
    require '/scripts/providers/stripe.v2'
    @model.once 'sync', @render, @
  render: ->
    @$el.html @tmpl()

    @$form = @$('form')
    @$form.on 'submit', (e) => 
      e.preventDefault()
      # Disable the submit button to prevent repeated clicks
      @$('button').prop 'disabled', true
      Stripe.card.createToken @$form, @stripeResponseHandler
      false

    @
  stripeResponseHandler: (status, response) =>
    if response.error
      # Show the errors on the form
      @$('.payment-errors').text response.error.message
      @$('button').prop 'disabled', false
    else 
      # token contains id, last4, and card type
      token = response.id
      # Insert the token into the form so it gets submitted to the server
      # $form.append($('<input type="hidden" name="stripeToken" />').val(token));
      # // and submit   
      email = @session.get('google')._json.email
      @model.save stripeCreate: { token: token, email: email }, { success: @stripeCustomerSuccess }

  stripeCustomerSuccess: (model, resp, opts) =>
    @$el.html 'success'
    @model.unset 'stripeCreate'    


class exports.StripeSettingsView extends BB.BadassView
  el: '#stripeSettings'
  tmpl: require './templates/StripeSettings'  
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    stripeSettings = @model.paymentMethod 'stripe'
    if stripeSettings?
      @$el.html 'stripe is setup'
    else  
      @$el.html "<a href='#stripe'>add stripe</a>" 

#############################################################################
##
#############################################################################


class exports.PayalSettingsView extends BB.ModelSaveView
  el: '#paypalSettings'
  tmpl: require './templates/PaypalSettings'
  events:
    'click .save': 'save'
  initialize: ->
    @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl()
    paypalSettings = @model.paymentMethod('paypal')
    if paypalSettings? then @elm('paypalEmail').val paypalSettings.email
    @
  getViewData: ->
    pp = type: 'paypal', isPrimary: true, info: { email: @elm('paypalEmail').val() }
    paymentMethods: [ pp ]


class exports.PaymentSettingsView extends BB.ModelSaveView
  el: '#paymentSettings'
  initialize: (args) ->
    @paypalView = new exports.PayalSettingsView args
    @stripeView = new exports.StripeSettingsView args


module.exports = exports