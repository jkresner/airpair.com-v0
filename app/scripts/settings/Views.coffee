exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##
#############################################################################

class exports.PaymentSettingsView extends BB.ModelSaveView
  el: '#paymentSettings'
  tmpl: require './templates/PaymentSettings'
  events:
    'click .save': 'save'
  initialize: ->
  render: ->
    @$el.html @tmpl @model.paymentMethod('paypal')
    @
  getViewData: ->
    pp = type: 'paypal', isPrimary: true, info: { email: @elm('paypalEmail').val() }
    paymentMethods: [ pp ]


module.exports = exports