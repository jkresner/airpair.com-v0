exports = {}
BB = require './../../lib/BB'
M = require './Models'
# SV = require './../shared/Views'

#############################################################################
## Shared across Expert Review + Experts View
#############################################################################

class exports.RegisterView extends BB.BadassView
  logging: on
  el: '#stripe'
  tmpl: require './templates/Register'
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
    $log 'got a customer yeah!', model.attributes

    @$el.html 'success'


module.exports = exports