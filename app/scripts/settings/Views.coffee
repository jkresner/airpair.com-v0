exports = {}
BB      = require './../../lib/BB'
M       = require './Models'
SV      = require './../shared/Views'


exports.StripeRegisterView = SV.StripeRegisterView


#############################################################################
##
#############################################################################


class exports.StripeSettingsView extends BB.BadassView
  el: '#stripeSettings'
  tmpl: require './templates/StripeSettings'
  initialize: (args) ->
    @listenTo @model, 'sync', @render
  render: ->
    stripeSettings = @model.paymentMethod 'stripe'
    @$el.html @tmpl {stripeSettings}


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
