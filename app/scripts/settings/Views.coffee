exports = {}
BB      = require './../../lib/BB'
M       = require './Models'

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
      @$('button').prop 'disabled', true  # Disable submitBtn to prevent repeat clicks
      Stripe.card.createToken @$form, @responseHandler
    @
  responseHandler: (status, response) =>
    if response.error # Show the errors on the form
      @$('.payment-errors').text response.error.message
      @$('button').prop 'disabled', false
    else
      token = response.id  # token contains id, last4, and card type
      @model.save stripeCreate: { token: token, email: @email() }, { success: @stripeCustomerSuccess }
  email: ->
    @session.get('google')._json.email
  stripeCustomerSuccess: (model, resp, opts) =>
    @model.unset 'stripeCreate'
    name = @session.get('google').displayName
    addjs.trackEvent 'request', 'customerSetStripeInfo', name
    addjs.providers.mp.setPeopleProps paymentInfoSet: 'stripe'
    @successAction()
  successAction: => # give the power to override this action so we can put the view in different flows
    router.navTo '#'


class exports.StripeSettingsView extends BB.BadassView
  el: '#stripeSettings'
  tmpl: require './templates/StripeSettings'
  initialize: (args) ->
    @listenTo @model, 'sync', @render
  render: ->
    stripeSettings = @model.paymentMethod 'stripe'
    @$el.html @tmpl {stripeSettings}


#############################################################################
##
#############################################################################


class exports.PayalSettingsView extends BB.ModelSaveView
  el: '#paypalSettings'
  tmpl: require './templates/PaypalSettings'
  events:
    'click .save': 'save'
  initialize: ->
    @listenTo @model, 'sync', @render
  render: ->
    @$el.html @tmpl()
    paypalSettings = @model.paymentMethod('paypal')
    if paypalSettings? then @elm('paypalEmail').val paypalSettings.info.email
    @
  getViewData: ->
    pp = type: 'paypal', isPrimary: true, info: { email: @elm('paypalEmail').val() }
    paymentMethods: [ pp ]


class exports.PaymentSettingsView extends BB.ModelSaveView
  el: '#payment'
  initialize: (args) ->
    @paypalView = new exports.PayalSettingsView args
    @stripeView = new exports.StripeSettingsView args


module.exports = exports
